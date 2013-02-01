
var hours = ['midnight','1am','2am','3am','4am','5am','6am','7am','8am','9am','10am','11am','noon','1pm','2pm','3pm','4pm','5pm','6pm','7pm','8pm','9pm','10pm','11pm','midnight'];

var MAX_DAYS = 30;
var MAX_PRICE = 50;
var MAX_HOURS = 24;
var MAX_SECONDS = 86400;
var ANY_TIME_TEXT = "Any Time";
var ANY_PRICE_TEXT = "Any Price";
var ANY_TAG_TEXT = "Any Category";

var O_ANYDAY = 0;
var O_TODAY = 1;
var O_THISWEEK = 2;
var O_CUSTOM = 3;

var infiniteScrolling = false;
var reloadTagsList = true;

var typingTimer;               //timer identifier
var doneTypingInterval = 1000;  //time in ms

function pushFilterTag(tag_id) {
  if(filter.included_tags.indexOf(tag_id) === -1) {
    filter.included_tags.push(tag_id);
  }
}

function popFilterTag(tag_id) {
  if(filter.included_tags.indexOf(tag_id) != -1) {
    filter.included_tags.splice(filter.included_tags.indexOf(tag_id),1);
  }
}

function inFilterTag(tag_id) {
  return !(typeof filter.included_tags === 'undefined' || filter.included_tags.indexOf(tag_id) === -1);
}

$(window).load(function() {
  streamSelector();
  updateViewFromFilter(false, {showSaveSearchButton: false});
});

$(function() {

  $("#header .filter-inner, #header .advancedbar").on("click", '.tags-menu.children .name', function() {
    $(this).siblings('.include').click();
  });

  // onclick include or exclude tags
  $("#header .filter-inner, #header .advancedbar").on("click", '.tags-menu.parents .include', function(event) {
    stopPropagation(event);

    var tagID = $(this).attr('tag-id');

    //remove all child tags from included_tags
    for(var i in tags[tagID]["child_ids"]) {
      popFilterTag(tags[tagID]["child_ids"][i]);
    }

    //toggle tag in included_tags
    if($(this).hasClass('selected')) {
      popFilterTag(tagID);
    } else {
      pushFilterTag(tagID);
    }

    var tagString = "";
    for(var i in filter.included_tags) {
      tagString += tags[filter.included_tags[i]]["name"] + ",";
    }
    console.log(tagString);

    reloadTagsList = false;
    updateViewFromFilter();
  });

  $("#header .filter-inner, #header .advancedbar").on("click", '.tags-menu.children .include', function(event) {
    event.stopPropagation();

    var tagID = $(this).attr('tag-id');

    // if this is selected
    if($(this).hasClass('selected')) {
      var parent_id = tags[tagID]["parent_id"];
      var parent_tag = tags[parent_id];
      // if the parent is in included_tags
      if(inFilterTag(parent_id)) {
        // then remove the parent tag from included_tags
        popFilterTag(parent_id);
        
        // and add all the parent's child tags to included_tags
        for(var i in parent_tag["child_ids"]) {
          pushFilterTag(parent_tag["child_ids"][i]);
        }
        // and remove the tag from included_tags
        popFilterTag(tagID);
      } else {  // otherwise just remove the tag from included_tags 
        popFilterTag(tagID);
      }
    // if this isn't selected
    } else {
      // add the tag to included_tags
      pushFilterTag(tagID);
      
      var parent_id = tags[tagID]["parent_id"];
      var parent_tag = tags[parent_id];
      var allChildrenInFilterTag = true;
      for(var i in parent_tag["child_ids"]) {
        if(!inFilterTag(parent_tag["child_ids"][i])) {
          allChildrenInFilterTag = false;
          break;
        }
      }
      // if all of the tag's parent's child tags are in included_tags
      if(allChildrenInFilterTag) {
        // then remove all the child tags from included_tags
        // and add the parent tag to included_tags
        for(var i in parent_tag["child_ids"]) {
          popFilterTag(parent_tag["child_ids"][i]);
        }
        pushFilterTag(parent_id);
      }
    }

    var tagString = "";
    for(var i in filter.included_tags) {
      tagString += tags[filter.included_tags[i]]["name"] + ",";
    }
    console.log(tagString);

    reloadTagsList = false;
    updateViewFromFilter();
  });

  // onclick for removing tags when they're clicked in the tag display box
  $("#header .filter-inner, #header .advancedbar").on("click", ".tags-display .tag", function() {

    var tagID = $(this).attr('tag-id');

    //remove this tag from included_tags
    popFilterTag(tagID);

    //remove this tag's child tags from included_tags
    for(var i in tags[tagID]["child_ids"]) {
      popFilterTag(tags[tagID]["child_ids"][i]);
    }

    reloadTagsList = false;
    updateViewFromFilter();
  });

  // accordion for tag menu

  $("#header .filter-inner, #header .advancedbar").on("mouseover", '.tags-menu.parents .tag-header', function1);
  $("#header .filter-inner, #header .advancedbar").on("click", '.tags-menu.parents .tag-header', function1);

  function function1() {
    $('.tags-menu .toggler').removeClass('icon-caret-right').addClass('icon-chevron-right');
    $(this).find('.toggler').addClass('icon-caret-right').removeClass('icon-chevron-right');
    $('.tags-menu.parents li').removeClass('selected');
    $(this).parent().addClass('selected');
    var parentTagID = $(this).attr("tag-id");
    
    $('.tags-menu.children li').hide();
    $(".tags-menu.children li[parent-id='" + parentTagID + "']").show();
  }

  $('#header').on('click', '.stream:not(.new, .selected, .bookmark)', function() {
    
    var streamID = $(this).attr('stream-id') || 0;

    filter = $.extend(true, {}, channelFilters[streamID]);
    updateViewFromFilter(true, {hideSaveSearchButton: true});
  });

  $('.filter-summary').on('click', '.filter', function() {
    if($(this).hasClass("datetime")) {
      filter.start_date = "";
      filter.end_date = "";
      filter.start_seconds = 0;
      filter.end_seconds = 86400;
      filter.start_days = 0;
      filter.end_days = -1;
      filter.day = [0,1,2,3,4,5,6];
    } else if($(this).hasClass("price")) {
      filter.low_price = "";
      filter.high_price = "";
    } else if($(this).hasClass("tags")) {
      filter.included_tags = [];
    } else if($(this).hasClass("search")) {
      filter.search = "";
    }
    updateViewFromFilter();
  });

  $('.filter.sort .filters').on('click', 'span', function() {    
    if($(this).hasClass('popularity'))
      filter.sort = 0;
    else if($(this).hasClass('date'))
      filter.sort = 1;

    updateViewFromFilter();
  });

  $('.custom-start, .custom-end').datepicker({
    minDate: 0,
    onSelect: function() {
      filter.start_date = $('.custom-start').datepicker("getDate").toString("yyyy-MM-dd");
      filter.end_date = $('.custom-end').datepicker("getDate").toString("yyyy-MM-dd");
      updateViewFromFilter();
    }
  });

  $('.custom-start, .custom-end').datepicker("setDate",Date.today().toString("MM/dd/yyyy"));

  $(".price-range").slider({
    range: true,
    min: 0,
    max: MAX_PRICE,
    values: [ 0, MAX_PRICE ],
    slide: function( event, ui ) {
      filter.low_price = (ui.values[0] === 0) ? "" : ui.values[0];
      filter.high_price = (ui.values[1] === MAX_PRICE) ? "" : ui.values[1];
      updateViewFromFilter(false);
    },
    stop: updateViewFromFilter
  });

  $(".time-range").slider({
    range: true,
    min: 0,
    max: MAX_HOURS,
    values: [ 0, MAX_HOURS ],
    slide: function( event, ui ) {
      if (ui.values[0] === ui.values[1])
        return false;

      filter.start_seconds = (ui.values[0] === 0) ? "" : ui.values[0] * 3600;
      filter.end_seconds = (ui.values[1] === MAX_HOURS) ? MAX_SECONDS : ui.values[1] * 3600;
      updateViewFromFilter(false);
    },
    stop: updateViewFromFilter
  });  

  $('.day-of-week > div').click(function() {
    var index = parseInt($(this).attr('day-of-week'));
    if(filter.day.length == 7) {
      filter.day = [index];
    } else {
      if(filter.day.indexOf(index) == -1) {
        filter.day.push(index);
      } else {
        filter.day.splice(filter.day.indexOf(index),1);
      }
    }

    if(filter.day.length == 0) {
      filter.day = [0,1,2,3,4,5,6];
    }

    filter.day.sort();
    updateViewFromFilter();
  });

  $('.filter.date .filters span').click(function () {
    filter.start_days = 0;
    filter.end_days = -1;
    filter.day = [0,1,2,3,4,5,6];
    filter.start_date = "";
    filter.end_date = "";


    switch($(this).index()) {
      //any day
      case 0:
        break;
      //today
      case 1:
        filter.start_days = 0;
        filter.end_days = filter.start_days;
        break;
      //this week
      case 2:
        filter.start_days = 0;
        filter.end_days = 6;
        var filterDays = [];
        $('.selected[day-of-week]').each(function() { filterDays.push(parseInt($(this).attr('day-of-week'))); });
        filter.day = filterDays;
        break;
      //custom
      case 3:
        filter.start_date = $('.custom-start').datepicker("getDate").toString("yyyy-MM-dd");
        filter.end_date = $('.custom-end').datepicker("getDate").toString("yyyy-MM-dd");
        break;
    }
    updateViewFromFilter();
  });

  $('#unnecessarily-long-id-for-toggling-search-on-map-move-and-zoom').click(function() {
    updateBoundsFlag = $(this).prop("checked");
  });

  //on keyup, start the countdown
  $('.search-input').keyup(function(){
    console.log("keyup");
      typingTimer = setTimeout(doneTyping, doneTypingInterval);
  });

  //on keydown, clear the countdown 
  $('.search-input').keydown(function(){
    console.log("keydown");
      clearTimeout(typingTimer);
  });

  var slideTime = 0;
  $('.filter-toggle:not(.search):not(.filter-action) .filter-text').click(function(event) {

    var thisToggle = $(this).parents('.filter-toggle');
    
    var otherToggled = thisToggle.siblings('.filter-toggle.selected');
    
    otherToggled.find('.filter-dropdown').slideUp(slideTime, function() { otherToggled.removeClass('selected'); });

    if (thisToggle.hasClass('selected')) {
      // $('#header').removeClass('selected');
      thisToggle.find('.filter-dropdown').slideUp(slideTime, function() { thisToggle.removeClass('selected'); });
    } else {
      // $('#header').addClass('selected');
      thisToggle.addClass('selected');
      thisToggle.find('.filter-dropdown').slideDown(slideTime);
    }
  });

  $('.filter-toggle:not(.filter-action)').click(function(event) {
    stopPropagation(event);
  });

  $('#ui-datepicker-div').click(function(event) {
    stopPropagation(event);
  });

  $('html').click(function() {
    $('.filter-toggle.selected .filter-text').click();
  });

  $('.filter-action.action-clear').click(function() {
    $('#header').removeClass('selected');
    filter = $.extend(true, {}, channelFilters[0]);
    updateViewFromFilter();
  });

  $('#body').scroll(checkInfinite);
  $(window).resize(checkInfinite);

});





function updateViewFromFilter(pullEventsFlag, options) {

  options = defaultTo(options, {});
  pullEventsFlag = defaultTo(pullEventsFlag, true);
  filter.offset = 0;

  //if filter.changed, show save search button
  //otherwise, hide save search button

  if(options.hideSaveSearchButton === true) {
    $('.filter-action.action-save').hide();
  } else if(options.showSaveSearchButton !== false) {
     $('.filter-action.action-save').show();
  }

  option_day = 0;
  if(filter.start_date !== "" || filter.end_date !== "") {
    option_day = O_CUSTOM;
  } else if(filter.start_days === 0 && filter.end_days === 6) {
    option_day = O_THISWEEK;
  } else if(filter.start_days === 0 && filter.end_days === -1) {
    option_day = O_ANYDAY;
  } else if(filter.start_days === 0 && filter.end_days === 0) {
    option_day = O_TODAY;
  } else {
    console.log(filter);
    console.log("option_day assignment error");
  }

  //tags header
  var filterText = "";
  
  $('.include').removeClass('selected').removeClass('icon-check').addClass('icon-check-empty');

  for(var i in filter.included_tags) {
    $('.include[tag-id='+filter.included_tags[i]+']').addClass('selected').removeClass('semi-selected').addClass('icon-check').removeClass('icon-check-empty');
    $('[parent-id=' + filter.included_tags[i] + '] .include').addClass('selected').addClass('icon-check').removeClass('icon-check-empty');
    var parent_id = tags[filter.included_tags[i]]["parent_id"];
    if(parent_id) {
      if(!inFilterTag(parent_id)) {
        $('.include[tag-id=' + parent_id + ']').addClass('selected').addClass('icon-check').removeClass('icon-check-empty');
      }
    }
  }

  var filterTextArr = [];
  var tagDisplayArr = [];

  $('.tags-menu.parents .tag-header').each(function() {
    //get list of parent tags in same order of appearance on page and iterate
    var parent_id = $(this).attr('tag-id');
    var parent_tag = tags[parent_id];

    if(inFilterTag(parent_id)) {
      //if parent is in included_tags print out parent's name
      filterTextArr.push(parent_tag["name"]);
      tagDisplayArr.push({id: parent_id, name: parent_tag["name"]});
    } else {
      //otherwise find intersection of parent's children and included_tags
      var included_child_ids = _.intersection(parent_tag["child_ids"], filter.included_tags);

      if(included_child_ids.length < 4) {
        //if size of intersection is <4 print out child tags' names
        for(var i in included_child_ids) {
          filterTextArr.push(tags[included_child_ids[i]]["name"]);
          tagDisplayArr.push({id: included_child_ids[i], name: tags[included_child_ids[i]]["name"]});
        }
      } else if(included_child_ids.length === parent_tag["child_ids"].length-1) {
        //otherwise if size of intersection =n-1 print out "[parent](except [missing child])"
        var orphan_id = _.difference(parent_tag["child_ids"],included_child_ids);
        filterTextArr.push(parent_tag["name"] + " (except " + tags[orphan_id]["name"] + ")");
        tagDisplayArr.push({id: parent_id, name: parent_tag["name"] + " (except " + tags[orphan_id]["name"] + ")"});
      } else {
        //otherwise print out "[size] [parent name] tags"
        filterTextArr.push(included_child_ids.length + " " + parent_tag["name"] + " Tags");
        tagDisplayArr.push({id: parent_id, name: included_child_ids.length + " " + parent_tag["name"] + " Tags"});
      }
    }
  });
  
  filterText = filterTextArr.join("/");

  if (filterText === "")
    filterText = ANY_TAG_TEXT;

  $('.filter-toggle.tags .text-inner').html(filterText);
  
  //tags selection
  $('.tags-display').empty();  
  for(var i in tagDisplayArr) {
    $('.tags-display').append("<span class='tag included' tag-id='" + tagDisplayArr[i]["id"] + "'><span class='include icon-check'></span><span class='name'>" + tagDisplayArr[i]["name"] + "</span></span>");
  }

  ////////////// DATETIME ////////////// 

  $('.filter.date .filters span').removeClass('selected');
  $('.filter.date .filters span:nth-child(' + (option_day + 1) + ')').addClass('selected');

  $('.filter.date .custom-select').removeClass('selected');
  $('.filter.date .custom-select:nth-child(' + (option_day + 1) + ')').addClass('selected');

  //time
  var start_hours = (filter.start_seconds === "") ? 0 : filter.start_seconds / 3600;
  var end_hours = (filter.end_seconds === "") ? MAX_HOURS : filter.end_seconds / 3600;

  $(".custom-select:nth-child(" + (option_day + 1) +  ") .time-range").slider("values", 0, start_hours);
  $(".custom-select:nth-child(" + (option_day + 1) +  ") .time-range").slider("values", 1, end_hours);

  //time string
  var timeStr = "";
  var timePreStr = "";
  if(start_hours === 0 && end_hours === MAX_HOURS) {
    timeStr = ANY_TIME_TEXT;
  } else {
    if(end_hours === MAX_HOURS) {
      timeStr = "<em>" + hours[start_hours] + "</em>";
      timePreStr = "after ";
    } else if(start_hours === 0) {
      timeStr = "<em>" + hours[end_hours] + "</em>";
      timePreStr = "before ";
    } else {       
      var timeOne = hours[start_hours];
      var timeTwo = hours[end_hours];
      timeStr = "<em>" + timeOne + "&ndash;" + timeTwo + "</em>";
      timePreStr = "";
    }
  }

  $(".custom-select:nth-child(" + (option_day + 1) +  ") .time-display").html(timePreStr + " " + timeStr);

  //date
  if(filter.start_date !== "") {
    console.log(filter.start_date);
    var parsedDate = $.datepicker.parseDate('yy-mm-dd', filter.start_date);
    $('.custom-start').datepicker("setDate",parsedDate);
  }
  if(filter.end_date !== "") {
    console.log(filter.end_date);
    var parsedDate = $.datepicker.parseDate('yy-mm-dd', filter.end_date);
    $('.custom-end').datepicker("setDate",parsedDate);
  }

  var dateStr = "";
  var datePreStr = "during ";
  var dow_short = ['Su','M','T','W','Th','F','Sa'];
  var dow_medium = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];
  var dow_long = ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'];
  if(option_day === O_ANYDAY) {
    dateStr = "";
  } else if(option_day === O_TODAY) {
    datePreStr = "";
    dateStr = "Today";
  } else if(option_day === O_THISWEEK) {
    if(filter.day.length === 7) {
      datePreStr = "";
      dateStr = "This Week";
    } else {
      var num_days = filter.day.length;
      for(var i in filter.day) {
        if(num_days === 1) {
          dateStr += "+" + dow_long[filter.day[i]];
        } else if(num_days === 2) {
          dateStr += "+" + dow_medium[filter.day[i]];
        } else {
          dateStr += "/" + dow_short[filter.day[i]];
        }
      }
      dateStr = dateStr.substring(1);
    }
  } else if(option_day === O_CUSTOM) {
    dateStr = $('.custom-start').datepicker("getDate").toString("MM/dd") + "&ndash;" + $('.custom-end').datepicker("getDate").toString("MM/dd")
  }

  var titleStr = "";
  var titlePreStr = "";
  if(dateStr === "") {
    titleStr = timePreStr + timeStr;
  } else {
    titlePreStr = datePreStr;
    if(timeStr === ANY_TIME_TEXT) {
      titleStr = dateStr;
    } else {
      titleStr = dateStr + " " + timePreStr + timeStr;
    }
  }

  $('.day-of-week > div').removeClass('selected');
  for(var i in filter.day) {
    $('.day-of-week > div[day-of-week=' + filter.day[i] + ']').addClass('selected');
  }

  //$('.filter-toggle.date .pre-text').html(titlePreStr);
  $('.filter-toggle.date .text-inner').html(titleStr);

  ////////////// PRICE //////////////

  var low_price = (filter.low_price === "") ? 0 : filter.low_price;
  var high_price = (filter.high_price === "") ? MAX_PRICE : filter.high_price

  //price selection and header
  $(".price-range").slider("values", 0, low_price);
  $(".price-range").slider("values", 1, high_price);

  var priceStr;
  if(low_price === 0 && high_price >= MAX_PRICE) {
    priceStr = ANY_PRICE_TEXT;
  } else {
    if(high_price >= MAX_PRICE) {
      priceStr = "Over $" + low_price;
    } else if(low_price === high_price) {
      priceStr = (low_price === 0 ? "Free" : "$" + low_price);
    } else if(low_price === 0) {
      priceStr = "Under $" + high_price;
    } else {
      var priceOne = "$" + low_price;
      var priceTwo = "$" + high_price;
      priceStr = priceOne + " - " + priceTwo;
    }
  }

  $('.price-display, .filter-toggle.price .text-inner').html(priceStr);

  ////////////// SORT //////////////

  //sort
  var sortStr = "";
  $('.filter.sort .filters span').removeClass('selected');
  if(filter.sort === 0) {
    $('.filter.sort .filters span.popularity').addClass('selected');
    sortStr = "Popularity";
  } else if(filter.sort === 1) {
    $('.filter.sort .filters span.date').addClass('selected');
    sortStr = "Date";
  }
  $('.filter-toggle.sort .text-inner').html(sortStr);

  ////////////// SEARCH ////////////// 

  if(!(options.update_search === false)) {
    $('.search-input').val(filter.search);
  }

  ////////////// FILTER SUMMARY //////////////

  if(titleStr === ANY_TIME_TEXT) {
    $('.filter-summary .datetime').hide();
    $('.filter-summary .datetime').html("");
  } else {
    $('.filter-summary .datetime').html(titlePreStr + titleStr);
    $('.filter-summary .datetime').show();
  }

  if(priceStr === ANY_PRICE_TEXT) {
    $('.filter-summary .price').hide();
    $('.filter-summary .price').html("");
  } else {
    $('.filter-summary .price').html(priceStr);
    $('.filter-summary .price').show();
  }

  if(filterText === ANY_TAG_TEXT) {
    $('.filter-summary .tags').hide();
    $('.filter-summary .tags').html("");
  } else {
    $('.filter-summary .tags').html(filterText);
    $('.filter-summary .tags').show();
  }

  if(filter.search === "") {
    $('.filter-summary .search').hide();
    $('.filter-summary .search').html("");
  } else {
    $('.filter-summary .search').html("&lsquo;" + filter.search + "&rsquo;");
    $('.filter-summary .search').show();
  }

  if(pullEventsFlag) {
    pullEvents();
  }
}

function streamSelector() {
  $('#dk_container_stream-select').remove();
  $('.streambar .stream.selector').remove();

  var parentWidth = $('.streambar .header').width() - $('.action-save').outerWidth(true); /* - $('.action-bookmarks').outerWidth(true) -  - $('.action-clear').outerWidth(true)*/; //- $('.stream.new').width();
  var sumWidth = 0;
  var maxWidth = 0;
  var overflowIndex = 0;
  // dropdown creator
  $('.streambar .header .stream').each(function(index) {
    
    sumWidth += $(this).outerWidth(true);

    // console.log("[" + index + "] " + $(this).text() + ":");
    // console.log("width: " + $(this).outerWidth(true));
    // console.log("sumWidth: " + sumWidth);
    // console.log("parentwidth: " + parentWidth);   
    // console.log("");
    
    if(sumWidth > parentWidth && overflowIndex === 0) {
      overflowIndex = index;
    }
    
    if(overflowIndex != 0) {
      maxWidth = Math.max(maxWidth,$(this).outerWidth(true)+36);
    }
  });

  // console.log("overflowIndex: " + overflowIndex);
  // console.log("");

  //if there are overflowed streams, make a stream dropdown
  if(overflowIndex != 0) {
    var streamSelect = $("<select name='stream-select' class='stream selector' style='position:absolute;top:0;right:0;'></select>");
    sumWidth = 0;
    $('.streambar .stream').each(function(index) {
      sumWidth += $(this).outerWidth(true);
      // console.log($(this).text() + ":");
      // console.log("width: " + $(this).outerWidth());
      // console.log("sumWidth: " + sumWidth);
      // console.log("parentwidth: " + parentWidth);   
      // console.log("");
      if(index >= overflowIndex || (sumWidth + maxWidth + 24 > parentWidth)) {
        streamSelect.append("<option value='" + $(this).attr("stream-id") + "'>" + $(this).text() + "</option>");
        $(this).hide();
      } else {
        $(this).show();
      }
    });

    $('.stream:nth-child(' + overflowIndex + ')').after(streamSelect);
    $('.streambar .stream.selector').dropkick({
      theme: "alegreya",
      width: maxWidth,
      change: function (value, label) {
        $("#dk_container_stream-select").addClass('selected');
        // $(".streambar .stream").removeClass('selected');
        // $('#header').addClass('selected');

        var channelID = parseInt(value);
        filter = $.extend(true, {}, channelFilters[channelID]);

        updateViewFromFilter(true, {hideSaveSearchButton: true});
      }
    });
  } else {
    $('.streambar .stream').show();
  }
}

//user is "finished typing," do something
function doneTyping () {
    filter.search = $('.search-input').val();
    pullEvents({update_search: false});
}

var boundsChangedFlag = false;
var updateBoundsFlag = true;
function boundsChanged() {
  if(updateBoundsFlag) {
    filter.lat_min = map.getBounds().getSouthWest().lat();
    filter.lat_max = map.getBounds().getNorthEast().lat();
    filter.long_min = map.getBounds().getSouthWest().lng();
    filter.long_max = map.getBounds().getNorthEast().lng();
    if(boundsChangedFlag) {
      updateViewFromFilter(true, {showSaveSearchButton: false});
    }
    boundsChangedFlag = true;
  }
}

// this gets called on infinite scroll and on filter changes
function pullEvents(updateOptions) {
  var async_reloadTagsList = reloadTagsList;
  var async_infiniteScrolling = infiniteScrolling;

  updateOptions = defaultTo(updateOptions, {});

  // console.log("pullEvents");
  // console.log("infiniteScrolling: " + infiniteScrolling);
  // console.log("reloadTagsList: " + reloadTagsList);
  // console.log(filter);

  loading('show');

  var visibleTagListID = $('.tags-menu.children li:visible').attr('parent-id');
  $.get("/events/index?ajax=true", filter, function (data) {
    var locations = [];

    var jData = $(data);

    if(async_infiniteScrolling) {
      $('#content .main .inner .events').append(jData.find("#combo_event_list").html());
      infiniteScrolling = false;
    } else {
      $('#content .main .inner .events').html(jData.find("#combo_event_list").html());
      $('.filter-summary .num-events').html(jData.find("#combo_total_occurrences").html());
      if(async_reloadTagsList) {
        $('#header .filter-toggle.tags .filter-inner').html(jData.find("#combo_tag_list").html());
        $('#header .advancedbar .tags-list').html(jData.find("#combo_advanced_tag_list").html());
      } else {
        reloadTagsList = true;
      }
    }

    if(visibleTagListID) {
      $("li[parent-id='" + visibleTagListID + "']").show();
      //$('.tag-header[tag-id=' + visibleTagListID + '] .toggler').html("&#x25BC;");
    }

    $('#content .main .inner .events li').each(function(index) {
      locations.push({lat: $(this).find('.latitude').html(), 
                     long: $(this).find('.longitude').html()});
    });

    placeMarkers({points: locations});

    loading('hide');

    updateOptions.showSaveSearchButton = false;
    updateViewFromFilter(false, updateOptions);
    
    // gotta jiggle the handle for position:fixed elements on resize, i think? weird.
    //var top = $('#map-wrapper').position().top;
    //$('#map-wrapper').css("top",(top + 1) + "px");
    
    if(!async_infiniteScrolling) {
      $('#body').scrollTop(Math.min($('#body').scrollTop(),$('#header .one').outerHeight()));
    }
    checkScroll();
  });
}

var pulling = false;
function loading(command) {
  if (command === 'show') {
    pulling = true;
    if(!infiniteScrolling) {
      var top = $('.main .inner .events').scrollTop();
      var bottom = $('.main .inner .events').height() - Math.max(0,$('.main .inner .events').height() + $('.main .inner .events').offset().top - $(window).height() - $(window).scrollTop());
      var y = (top + bottom) / 2 - 33;
      var x = $('.main .inner .events').width() / 2 - 33;
      $('.main .inner .header, .main .inner .events').css('opacity','.5');
      if(y > 0) {
        $('#loading').css('top', y + 'px');
        $('#loading').css('left', x + 'px');
        $('#loading').show();
      }
    } else {
      $('#infinite-loader').show();
    }
  } else if (command === 'hide') {
    $('.main .inner .header, .main .inner .events').css('opacity','1');
    $('#loading').hide();
    $('#infinite-loader').hide();
    pulling = false;
  }
}

function checkInfinite() {
  //console.log("checkInfinite");
  //if we're near the bottom of the page and not currently pulling in events
  if($('#body').scrollBottom() < 1000 && !pulling) {
    //console.log("pull em");
    //check if there are any more possible events to pull
    // if so, pull em.
    if($('#content .main .inner .events li:not(.no-results)').length < parseInt($('.filter-summary .num-events').html())) {
      infiniteScrolling = true;
      filter.offset = $('#content .main .inner .events li').length;
      pullEvents();
    }
  }
}