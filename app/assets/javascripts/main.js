/** jquery plugins **/

// checks if element has a scrollbar
$.fn.hasScrollBar = function() {
    return this.get(0).scrollHeight > this.innerHeight();
}

$.fn.scrollBottom = function() {
    return this[0].scrollHeight - this[0].scrollTop - this[0].clientHeight;
}

// finds browser's scrollbar width
var scrollbarWidth = 0;
$.getScrollbarWidth = function() {
  if ( !scrollbarWidth ) {
    if ( $.browser.msie ) {
      var $textarea1 = $('<textarea cols="10" rows="2"></textarea>')
          .css({ position: 'absolute', top: -1000, left: -1000 }).appendTo('body'),
        $textarea2 = $('<textarea cols="10" rows="2" style="overflow: hidden;"></textarea>')
          .css({ position: 'absolute', top: -1000, left: -1000 }).appendTo('body');
      scrollbarWidth = $textarea1.width() - $textarea2.width();
      $textarea1.add($textarea2).remove();
    } else {
      var $div = $('<div />')
        .css({ width: 100, height: 100, overflow: 'auto', position: 'absolute', top: -1000, left: -1000 })
        .prependTo('body').append('<div />').find('div')
          .css({ width: '100%', height: 200 });
      scrollbarWidth = 100 - $div.width();
      $div.parent().remove();
    }
  }
  return scrollbarWidth;
};

var defaultThing = { internal_url: function() { return "/" + this.type + "s/show/" + this.id; },
                     url: function() { return "?" + this.type + "_id=" + this.id; } };

var things = {
  "venue": spawn(defaultThing, {type: "venue"}),
  "event": spawn(defaultThing, {type: "event"}),
  "act": spawn(defaultThing, {type: "act"}),
  "shunt": spawn(defaultThing, {type: "shunt", internal_url: function() { return "/events/shunt"; }, url: function() { return "?shunt"; }}),
  "new-channel": spawn(defaultThing, {type: "new-channel", internal_url: function() { return "/channels/new"; }, url: function() { return "?new-channel"; }}),
  "new-channel-2": spawn(defaultThing, {type: "new-channel-2", internal_url: function() { return "/channels/new2"; }, url: function() { return "?new-channel-2"; }})
};

var mapOffset;

var hours = ['midnight','1am','2am','3am','4am','5am','6am','7am','8am','9am','10am','11am','noon','1pm','2pm','3pm','4pm','5pm','6pm','7pm','8pm','9pm','10pm','11pm','midnight'];

var MAX_DAYS = 30;
var MAX_PRICE = 50;
var MAX_HOURS = 24;
var MAX_SECONDS = 86400;
var ANY_TIME_TEXT = "Any Time";

var O_ANYDAY = 0;
var O_TODAY = 1;
var O_THISWEEK = 2;
var O_CUSTOM = 3;

var infiniteScrolling = false;
var reloadTagsList = true;

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
  return !(filter.included_tags.indexOf(tag_id) === -1);
}

$(function() {

  scrollbarWidth = $.getScrollbarWidth();


  $("#header .filter-inner, #header .advancedbar").on("click", '.tags-menu.children .name', function() {
    $(this).siblings('.include').click();
  });

  // onclick include or exclude tags
  $("#header .filter-inner, #header .advancedbar").on("click", '.tags-menu.parents .include', function(event) {
    event.stopPropagation();

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

  $("#header .filter-inner, #header .advancedbar").on("click", '.tags-menu.parents .tag-header', function() {
    $('.tags-menu .toggler').removeClass('icon-caret-right').addClass('icon-chevron-right');
    $(this).find('.toggler').addClass('icon-caret-right').removeClass('icon-chevron-right');
    $('.tags-menu.parents li').removeClass('selected');
    $(this).parent().addClass('selected');
    var parentTagID = $(this).attr("tag-id");
    
    $('.tags-menu.children li').hide();
    $(".tags-menu.children li[parent-id='" + parentTagID + "']").show();
  });

  $('#header').on('click', '.stream:not(.new)', function() {
    $("#dk_container_stream-select").removeClass('selected');
    $(this).siblings().removeClass('selected');
    $(this).addClass('selected');
    
    var channelID = $(this).attr('channel-id') || 0;
    filter = $.extend(true, {}, channelFilters[channelID]);

    updateViewFromFilter();
  });

  $('.sort-by').on('click', '.sort', function() {    
    if($(this).attr("sort-type") === "popularity")
      filter.sort = 0;
    else if($(this).attr("sort-type") === "date")
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
    filter.option_day = $(this).index();

    filter.start_days = 0;
    filter.end_days = "INFINITY";
    filter.day = [0,1,2,3,4,5,6];
    filter.start_date = "";
    filter.end_date = "";

    switch(filter.option_day) {
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
});

function defaultTo(parameter, parameterDefault) {
  return (typeof parameter !== 'undefined') ? parameter : parameterDefault;
}

function updateViewFromFilter(pullEventsFlag) {

  pullEventsFlag = defaultTo(pullEventsFlag, true);
  filter.offset = 0;

  ////////////// CHANNELS //////////////

  // var channelStr = filter.name === "" ? "All Events" : filter.name;
  // $('.filter-toggle.channels .text-inner').html(channelStr);

  ////////////// TAGS ////////////// 

  //tags header
  var filterText = "";
  
  $('.include').removeClass('selected').removeClass('icon-check').addClass('icon-check-empty');
  //$('.include img').attr('src','/assets/include2.png');
  for(var i in filter.included_tags) {
    $('.include[tag-id='+filter.included_tags[i]+']').addClass('selected').removeClass('semi-selected').addClass('icon-check').removeClass('icon-check-empty');
    $('[parent-id=' + filter.included_tags[i] + '] .include').addClass('selected').addClass('icon-check').removeClass('icon-check-empty');
    var parent_id = tags[filter.included_tags[i]]["parent_id"];
    if(parent_id) {
      if(!inFilterTag(parent_id)) {
        $('.include[tag-id=' + parent_id + ']').addClass('selected').addClass('icon-check').removeClass('icon-check-empty');
      }
    }
    //$('.include[tag-id='+filter.included_tags[i]+'] img').attr('src','/assets/include_select.png');
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
    filterText = "Any Tag";

  $('.filter-toggle.tags .text-inner').html(filterText);
  
  //tags selection
  $('.tags-display').empty();  
  for(var i in tagDisplayArr) {
    $('.tags-display').append("<span class='tag included' tag-id='" + tagDisplayArr[i]["id"] + "'><span class='include icon-check'></span><span class='name'>" + tagDisplayArr[i]["name"] + "</span></span>");
  }

  ////////////// DATETIME ////////////// 

  $('.filter.date .filters span').removeClass('selected');
  $('.filter.date .filters span:nth-child(' + (filter.option_day + 1) + ')').addClass('selected');

  $('.filter.date .custom-select').removeClass('selected');
  $('.filter.date .custom-select:nth-child(' + (filter.option_day + 1) + ')').addClass('selected');

  //time
  var start_hours = (filter.start_seconds === "") ? 0 : filter.start_seconds / 3600;
  var end_hours = (filter.end_seconds === "") ? MAX_HOURS : filter.end_seconds / 3600;

  $(".custom-select:nth-child(" + (filter.option_day + 1) +  ") .time-range").slider("values", 0, start_hours);
  $(".custom-select:nth-child(" + (filter.option_day + 1) +  ") .time-range").slider("values", 1, end_hours);

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

  $(".custom-select:nth-child(" + (filter.option_day + 1) +  ") .time-display").html(timePreStr + " " + timeStr);
  
  //date

  $(".date-range").slider("value", filter.start_days);

  var dateStr = "";
  var datePreStr = "during ";
  var dow_short = ['Su','M','T','W','Th','F','Sa'];
  var dow_medium = ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];
  var dow_long = ['Sunday','Monday','Tuesday','Wednesday','Thursday','Friday','Saturday'];
  if(filter.option_day === O_ANYDAY) {
    dateStr = "";
  } else if(filter.option_day === O_TODAY) {
    dateStr = "Today";
  } else if(filter.option_day === O_THISWEEK) {
    if(filter.day.length === 7) {
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
  } else if(filter.option_day === O_CUSTOM) {
    dateStr = $('.custom-start').datepicker("getDate").toString("MM/dd") + "&ndash;" + $('.custom-end').datepicker("getDate").toString("MM/dd")
  }

  var titleStr = "";
  var titlePreStr = "";
  if(dateStr === "") {
    titleStr = timePreStr + timeStr;
    // if(timePreStr !== "") {
    //   titlePreStr = timePreStr;
    // }
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
    priceStr = "Any Price";
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
  $('.sort-by .sort').removeClass('selected');
  if(filter.sort === 0) {
    $('.sort-by').html("Sorted by <span class='sort selected' sort-type='popularity'>popularity</span> / <span class='sort' sort-type='date'>date</span>");
  } else if(filter.sort === 1) {
    $('.sort-by').html("Sorted by <span class='sort selected' sort-type='date'>date</span> / <span class='sort' sort-type='popularity'>popularity</span>");
  }

  ////////////// SEARCH ////////////// 

  $('.search-input').val(filter.search);

  if(pullEventsFlag) {
    pullEvents();
  }
}


var advancedSlideTime, filterSlideTime, marginHeight, baseHeight, filterHeight, advancedHeight;
var typingTimer;               //timer identifier
var doneTypingInterval = 500;  //time in ms
$(function() {

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

  $('.mode.venue .address.one').click(function(){
     $('.mode').hide();
  });

  $('#content .sidebar .inner .filter.day span').click(function() {
    $('#content .sidebar .inner .filter.date span.custom').click();
  });  
  
  $(".mode .window .menu li").click(function() {
    var index = $(this).index();
    $(this).siblings().removeClass("selected");
    $(this).addClass("selected");
    $(this).parent().parent().children("div").removeClass("selected");
    $(this).parent().parent().children("div").eq(index).addClass("selected");
  });

  $('#content').on("mouseenter", ".events > li:not(.no-results)", function() {
    google.maps.event.trigger(markers[$(this).index()], 'mouseover');
  });

  $('#content').on("mouseleave", ".events > li:not(.no-results)", function() {
    google.maps.event.trigger(markers[$(this).index()], 'mouseout');
  });

  $('#body').scroll(showPageMarkers);
  $('#body').scroll(checkInfinite);
  $('#body').scroll(scrollHeader);
  
  $(window).resize(showPageMarkers);
  $(window).resize(checkScroll);
  $(window).resize(checkInfinite);
  $(window).resize(scrollHeader);

  // // oh god what a grody hack. TODO: find out why this happens and fixitfixitfixit
  // $('#content .main .inner .events, .venue.mode .events').on("click", ".linkto", loadModal);
  // $(".window .linkto").click(loadModal);

  var slideTime = 0;
  $('.filter-toggle:not(.search):not(.filter-action) .filter-text').click(function(event) {

    var thisToggle = $(this).parents('.filter-toggle');
    
    var otherToggled = thisToggle.siblings('.filter-toggle.selected');
    
    otherToggled.find('.filter-dropdown').slideUp(slideTime, function() { otherToggled.removeClass('selected'); });

    if (thisToggle.hasClass('selected')) {
      $('#header').removeClass('selected');
      thisToggle.find('.filter-dropdown').slideUp(slideTime, function() { thisToggle.removeClass('selected'); });
    } else {
      $('#header').addClass('selected');
      thisToggle.addClass('selected');
      thisToggle.find('.filter-dropdown').slideDown(slideTime);
    }
  });

  $('.filter-toggle:not(.filter-action)').click(function(event) {
    event.stopPropagation();
  });

  $('#ui-datepicker-div').click(function(event) {
    event.stopPropagation();
  });

  $('html').click(function() {
    $('.filter-toggle.selected .filter-text').click();
  });

  advancedSlideTime = 200;
  filterSlideTime = 100;
  
  marginHeight = 10;
  var oneH = $('#header .one').outerHeight();
  var streamH = $('.streambar').outerHeight();
  var filterH = $('.filterbar').outerHeight();
  var advancedH = $('.advancedbar').outerHeight();

  baseHeight = oneH + streamH + marginHeight;
  filterHeight = oneH + streamH + filterH + marginHeight;
  advancedHeight = oneH + streamH + advancedH + marginHeight;

  // console.log("oneH: " + oneH);
  // console.log("streamH: " + streamH);
  // console.log("filterH: " + filterH);
  // console.log("advancedH: " + advancedH);
  
  $('.expandobar-inner').click(function () {
    if($(this).hasClass('expanded')) {
      $('.advancedbar').slideUp(advancedSlideTime, function() {  $('.filterbar').slideDown(filterSlideTime) });
      $('#content, #map-wrapper, .subbar-wrapper').animate(
        { "margin-top" : baseHeight },
        advancedSlideTime, 
        function() { 
          $('#content, #map-wrapper, .subbar-wrapper').animate(
            {"margin-top" : filterHeight }, 
            filterSlideTime,
            checkScroll
          );
        }
      ); 
      $(this).removeClass('expanded');
      $(this).html("<span>&#9660;</span>show advanced options<span>&#9660;</span>");
    } else {
      $('.filterbar').slideUp(filterSlideTime, function() {  $('.advancedbar').slideDown(advancedSlideTime); });
      $('#content, #map-wrapper, .subbar-wrapper').animate(
        { "margin-top" : baseHeight },
        filterSlideTime, 
        function() { 
          $('#content, #map-wrapper, .subbar-wrapper').animate(
            {"margin-top" : advancedHeight }, 
            advancedSlideTime,
            checkScroll
          );
        }
      );
      $(this).addClass('expanded');
      $(this).html("<span>&#9650;</span>hide advanced options<span>&#9650;</span>");
    }
  });

  $("#content").on("click", "[linkto]", loadModal);
  $("#header").on("click", "[linkto]", loadModal);
  $('#overlays').on("click", "[linkto]", loadModal);
  $('#overlays').on("click", '.mode .close-btn', closeMode);
  $('#overlays').on("click", '.mode .add_bookmark', function() {
    $.post('/bookmarks/create',{
      bookmarked_id: $(this).attr('bookmarked_id'),
      bookmarked_type: $(this).attr('bookmarked_type')},
      function(data) {
        $('.mode .add_bookmark').hide();
        $('.mode .remove_bookmark').attr("bookmark-id",data.id);
        $('.mode .remove_bookmark').show();
      },"json"
    );
  });
  $('#overlays').on("click", '.mode .remove_bookmark', function() {
    $.ajax('/bookmarks/' + $(this).attr('bookmark-id'),{
      type: "DELETE",
      dataType: "json",
      success: function() {
        $('.mode .remove_bookmark').hide();
        $('.mode .add_bookmark').show();
      }
    });
  });

  $('.mode .overlay .background').click(closeMode);
  

  $('.filter-action.action-clear').click(function() {
    filter = $.extend(filter, channelFilters[0]);
    updateViewFromFilter();
  });

  // $('.filter-action.action-save').not('[linkto=shunt]').click(function() {
  //   console.log("save stream");
  //   if($('.lists li.selected').hasClass('channel')) {
  //     if(confirm("Are you sure you want to save " + $(".channels .lists li.selected").html() + "?")) {
  //       $.post('/channels/update/' + $(".channels .lists li.selected").attr('channel-id'), filter, function(channel) {

  //         channelFilters[channel.id] = {
  //             option_day: (channel.option_day === null) ? 0 : channel.option_day,
  //             start_days: (channel.start_days === null) ? 0 : channel.start_days,
  //             end_days: (channel.end_days === null) ? 0 : channel.end_days,
  //             start_seconds: (channel.start_seconds === null) ? '' : channel.start_seconds,
  //             end_seconds: (channel.end_seconds === null) ? '' : channel.end_seconds,
  //             low_price: (channel.low_price === null) ? '' : channel.low_price,
  //             high_price: (channel.high_price === null) ? '' : channel.high_price,
  //             included_tags: channel.included_tags ? channel.included_tags.split(",") : [],
  //             excluded_tags: channel.excluded_tags ? channel.excluded_tags.split(",") : [],
  //             lat_min: "",
  //             lat_max: "",
  //             long_min: "",
  //             long_max: "",
  //             offset: 0,
  //             search: "",
  //             sort: (channel.sort === null) ? 0 : channel.sort,
  //             name: (channel.name === null) ? '' : channel.name,
  //             start_date: "",
  //             end_date: ""
  //         };
  //       }, "json");
  //     }
  //   }
  // });

  // if($("#map").length > 0)
  //   mapOffset = $("#map").offset().top;

  checkScroll();

});

$(window).load(function() {
  streamSelector();
  initialize();
  updateViewFromFilter(false);
});

function streamSelector() {
  $('#dk_container_stream-select').remove();
  $('.streambar .stream.selector').remove();

  var parentWidth = $('.streambar .header').width() - $('.stream.new').width();
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
      maxWidth = Math.max(maxWidth,$(this).outerWidth(true));
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
        streamSelect.append("<option value='" + $(this).attr("channel-id") + "'>" + $(this).text() + "</option>");
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
        $(".streambar .stream").removeClass('selected');

        var channelID = parseInt(value);
        filter = $.extend(true, {}, channelFilters[channelID]);

        updateViewFromFilter();
      }
    });
  } else {
    $('.streambar .stream').show();
  }
}

function scrollHeader() {
  var headerTop = -(Math.min($('#body').scrollTop(),$('#header .one').outerHeight()));
  $('#header, #content #map-wrapper').css('top',headerTop+'px');
}

//user is "finished typing," do something
function doneTyping () {
    filter.search = $('.search-input').val();
    pullEvents();
}

window.addEventListener("popstate", function(e) {
  //console.log("popstate");
  //console.log(e);
  var query = e.target.location.search;
  if(query !== "") {
    modal(parsequery(query));
  } else {
    demodal();
  }
});

var boundsChangedFlag = false;
function boundsChanged() {
  filter.lat_min = map.getBounds().getSouthWest().lat();
  filter.lat_max = map.getBounds().getNorthEast().lat();
  filter.long_min = map.getBounds().getSouthWest().lng();
  filter.long_max = map.getBounds().getNorthEast().lng();
  if(boundsChangedFlag) {
    updateViewFromFilter();
  }
  boundsChangedFlag = true;
}

function closeMode() {
  //console.log("closeMode");
  history.pushState({}, "main mode", "/");
  demodal();
}

function placeMarkers(params) {
  if (typeof params.clear === 'undefined' || params.clear === true)
    clearMarkers();
  for(var i in params.points) {
    placeMarker(params.points[i].lat, params.points[i].long);
  }

  showPageMarkers();
}

function clearMarkers() {
  for(var i in markers) {
    markers[i].setMap(null);
  }
  markers = [];
}

function placeMarker(lat, long) {
  var i = markers.length;

  var marker = new google.maps.Marker({ //MarkerWithLabel({
    map: map,
    position: new google.maps.LatLng(lat,long),
    icon: "/assets/markers/marker_" + (i + 1) % 1 + ".png",
    index: i + 1
  });

  google.maps.event.addListener(marker, 'mouseover', function() {
    marker.setIcon("/assets/markers/marker_hover_" + marker.index % 1 +  ".png");
    $("#content .main .inner .events li:nth-child(" + marker.index + ")").addClass("hover");
  });

  google.maps.event.addListener(marker, 'mouseout', function() {
    marker.setIcon("/assets/markers/marker_" + marker.index % 1 + ".png");
    $("#content .main .inner .events li:nth-child(" + marker.index + ")").removeClass("hover");
  });

  google.maps.event.addListener(marker, 'click', function() {
    $("#content .main .inner .events li:nth-child(" + marker.index + ")").click();
  });

  markers.push(marker);
}

var fuzz = 1;
function showPageMarkers() {
  var numVisibleEvents = $('#content .main .inner .events li:in-viewport').length;
  if(numVisibleEvents > 0) {
    var start = parseInt($('#content .main .inner .events li:in-viewport .index').html());
    var end = start + numVisibleEvents - 1;
    start -= fuzz; end += fuzz;
    for(var i in markers) {
      markers[i].setVisible(markers[i].index >= start && markers[i].index <= end);
    }
  }
}

// this gets called on infinite scroll and on filter changes
function pullEvents() {
  console.log(filter);

  loading('show');

  var visibleTagListID = $('.tags-menu.children li:visible').attr('parent-id');
  $.get("/events/index?ajax=true", filter, function (data) {
    var locations = [];

    var jData = $(data);

    if(infiniteScrolling) {
      $('#content .main .inner .events').append(jData.find("#combo_event_list").html());
      infiniteScrolling = false;
    } else {
      $('#content .main .inner .events').html(jData.find("#combo_event_list").html());
      $('.num-occurrences-count').html(jData.find("#combo_total_occurrences").html());
      if(reloadTagsList) {
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

    updateViewFromFilter(false);
    
    // gotta jiggle the handle for position:fixed elements on resize, i think? weird.
    //var top = $('#map-wrapper').position().top;
    //$('#map-wrapper').css("top",(top + 1) + "px");

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
    }
  } else if (command === 'hide') {
    $('.main .inner .header, .main .inner .events').css('opacity','1');
    $('#loading').hide();
    pulling = false;
  }
}

function toggleSelection() {
  var thisSelected = ($(this).hasClass('selected'));
  if(thisSelected && $(this).siblings('span.selected').length == $(this).siblings('span').length) {
    $(this).siblings('span').removeClass('selected');
  } else if (thisSelected && $(this).siblings('span.selected').length == 0){
    $(this).siblings('span').addClass('selected');
  } else {
    $(this).toggleClass('selected');
  }
}

function radioSelection() {
  $(this).siblings('span').removeClass('selected');
  $(this).addClass('selected');
}


function checkScroll() {
  var mapWrapperWidth = 990;
  if($('#body').hasScrollBar()) {
    //$('#map-wrapper').width(mapWrapperWidth);
    $('#header').width($('#body').width() - scrollbarWidth);
  } else {
    //$('#map-wrapper').width(mapWrapperWidth + scrollbarWidth);
    $('#header').width($('#body').width());
  }
}

function checkInfinite() {
  //if we're near the bottom of the page and not currently pulling in events
  if($('#body').scrollBottom() < 100 && !pulling) {
    //check if there are any more possible events to pull
    // if so, pull em.
    if($('#content .main .inner .events li:not(.no-results)').length < parseInt($('.num-occurrences-count').html())) {
      infiniteScrolling = true;
      filter.offset = $('#content .main .inner .events li').length;
      pullEvents();
    }
  }
}

function loadModal(event) {
  console.log('loadModal');
  var thing = spawn(things[$(this).attr("linkto")],{id: $(this).attr("link-id")});
  //console.log(thing);
  //console.log(thing.type);
  //console.log(thing.id);
  //var thing = {type:$(this).attr("linkto"), id: $(this).attr("link-id")};
  if($(this).attr("linkto") !== "shunt" && $(this).attr("linkto") !== "new-channel" && $(this).attr("linkto") !== "new-channel-2" ) {
    history.pushState({}, thing.type + " mode", thing.url());
  }
  if($(this).is("#content .main .events li .venue")) {
     event.stopPropagation();
  }
  modal(thing);
  return false;
}

//only works for one parameter. lol.
function parsequery(query) {
  query = query.substring(1, query.length);
  var queryArr = query.split('=');
  if(queryArr[0] == "venue_id") {
    return spawn(things["venue"],{ id: queryArr[1] });
  } else if(queryArr[0] == "event_id") {
    return spawn(things["event"],{ id: queryArr[1] });
  } else if(queryArr[0] == "act_id") {
    return spawn(things["act"],{ id: queryArr[1] });
  } else if(queryArr[0] == "shunt") {
    return spawn(things["shunt"]);
  } else if(queryArr[0] == "new-channel") {
    return spawn(things["new-channel"]);
  } else {
    return null;
  }
}

function demodal() {
  //console.log("demodal");
  modal();
}

function to_ordinal(num) {
    var ordinal = ["th","st","nd","rd","th","th","th","th","th","th"] ;
    return num.toString() + ordinal[num%10];
}

function strip(html) {
  var tmp = document.createElement("DIV");
  tmp.innerHTML = html;
  return tmp.textContent || tmp.innerText;
}

function modal(thing) {
  //console.log("modal");
  //console.log(thing);
  if(!thing) {
    $('.mode').hide();
    $('.mode .insert-point').html("");
    return;
  } else {
    $.get(thing.internal_url(), function(data) {
     //$.get('/' + thing.type + 's/show/' + thing.id, function(data) {
      $('.mode').hide().removeClass().addClass('mode ' + thing.type);
      $('.mode').show();
      $('.mode .insert-point').html(data);
    });
  }
}

function deepExtend(destination, source) {
  for (var property in source) {
    if (source[property] && source[property].constructor &&
     source[property].constructor === Object) {
      destination[property] = destination[property] || {};
      arguments.callee(destination[property], source[property]);
    } else {
      destination[property] = source[property];
    }
  }
  return destination;
};

function spawn(classObject, extendParams) {
  if (typeof extendParams === 'undefined')
    return deepExtend({},classObject);
  else
    return deepExtend(deepExtend({},classObject),extendParams);
}
