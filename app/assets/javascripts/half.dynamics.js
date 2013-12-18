var hours = ['midnight', '1am', '2am', '3am', '4am', '5am', '6am', '7am', '8am', '9am', '10am', '11am', 'noon', '1pm', '2pm', '3pm', '4pm', '5pm', '6pm', '7pm', '8pm', '9pm', '10pm', '11pm', 'midnight'];

var MAX_DAYS = 30;
var MAX_PRICE = 50;
var MAX_HOURS = 24;
var MAX_SECONDS = 86400;
var ANY_TIME_TEXT = "Any Time";
var ANY_PRICE_TEXT = "Any Price";
var ANY_CATEGORY_TEXT = "Any Category";
var ANY_TAG_TEXT = "Any Tag";

var O_ANYDAY = 0;
var O_TODAY = 1;
var O_THISWEEK = 2;
var O_CUSTOM = 3;

var infiniteScrolling = false;
var reloadTagsList = true;

var typingTimer;               //timer identifier
var doneTypingInterval = 1000;  //time in ms

function pushFilterTag(tag_id, tag_type) {
  tag_type = defaultTo(tag_type, "included_tags");
  if (tag_type === "included_tags") {
    if (filter.included_tags.indexOf(tag_id) === -1) {
      filter.included_tags.push(tag_id);
    }
  } else if (tag_type === "and_tags") {
    if (filter.and_tags.indexOf(tag_id) === -1) {
      filter.and_tags.push(tag_id);
    }
  } else {
    console.log("excluded tag added")
    if (filter.excluded_tags.indexOf(tag_id) === -1) {
      filter.excluded_tags.push(tag_id);
    }
  }

}

function popFilterTag(tag_id, tag_type) {
  tag_type = defaultTo(tag_type, "included_tags");
  if (tag_type === "included_tags") {
    if (filter.included_tags.indexOf(tag_id) != -1) {
      filter.included_tags.splice(filter.included_tags.indexOf(tag_id), 1);
    }
  } else if (tag_type === "and_tags") {
    if (filter.and_tags.indexOf(tag_id) != -1) {
      filter.and_tags.splice(filter.and_tags.indexOf(tag_id), 1);
    }
  } else {
    if (filter.excluded_tags.indexOf(tag_id) != -1) {
      filter.excluded_tags.splice(filter.excluded_tags.indexOf(tag_id), 1);
    }
  }
}

function inFilterTag(tag_id, tag_type) {
  tag_type = defaultTo(tag_type, "included_tags");
  if (tag_type === "included_tags") {
    return !(typeof filter.included_tags === 'undefined' || filter.included_tags.indexOf(tag_id) === -1);
  } else if (tag_type === "and_tags") {
    return !(typeof filter.and_tags === 'undefined' || filter.and_tags.indexOf(tag_id) === -1);
  } else {
    return !(typeof filter.excluded_tags === 'undefined' || filter.excluded_tags.indexOf(tag_id) === -1);
  }
}

$(window).load(function () {
  streamSelector();
  updateViewFromFilter(false, {showSaveSearchButton: false});
});
var device = '';
$(function () {

  var uagent = navigator.userAgent.toLowerCase();

  if (uagent.search("iphone") > -1)
    device = 'mobile';

  else if (uagent.search("tablet") > -1)
    device = 'mobile';
  else if (uagent.search("ipad") > -1)
    device = 'mobile';
  else if (uagent.search("android") > -1)
    device = 'mobile';


  $("#header .filter-inner, #header .advancedbar").on("click", '.tags-menu.ortags.children .name', function () {
    $(this).siblings('.include').click();
  });

  $("#sxsw-tags").on("click", '.individual-tag .name', function (event) {
    stopPropagation(event);
    $('.tags-menu.ortags.children .include[tag-id=' + $(this).siblings('.include').attr("tag-id") + ']').click();
    $(".sxsw-channel-text").html("");
  });

  $("#sxsw-tags").on("click", '.individual-tag .include', function (event) {
    stopPropagation(event);
    $('.tags-menu.ortags.children .include[tag-id=' + $(this).attr("tag-id") + ']').click();
    $(".sxsw-channel-text").html("");
  });


  $("#sxsw-options").on("click", '.rsvp-button', function (event) {
    stopPropagation(event);
    filter = $.extend(true, {}, channelFilters[417]);
    $(".sxsw-channel-text").html("");
    updateViewFromFilter(true, {hideSaveSearchButton: true});
  });

  $('.access').dropkick({
    width: 185,
    display: "inline-block",
    change: function (value, label) {
      console.log("stream selected");
      $("#dk_container_stream-select").addClass('selected');
      var channelID = parseInt(value);
      // console.log(channelID);
      filter = $.extend(true, {}, channelFilters[channelID]);
      console.log($(".access [stream-id='" + channelID + "']").attr("filter-text"));
      $(".sxsw-channel-text").html($(".access [stream-id='" + channelID + "']").attr("filter-text"));
      updateViewFromFilter(true, {hideSaveSearchButton: true});
    }
  });


  $('.sxsw-dates').dropkick({
    width: 155,
    display: "inline-block",
    change: function (value, label) {
      switch (parseInt(value)) {
        case 0:
          filter.start_date = "";
          filter.end_date = "";
          break;
        case 1:
          //Today
          filter.start_date = Date.today().toString("yyyy-MM-dd");
          console.log(Date.today().toString("yyyy-MM-dd"));
          filter.end_date = Date.today().toString("yyyy-MM-dd");
          break;
        case 2:
          // Interactive
          filter.start_date = '2013-03-08';
          filter.end_date = '2013-03-12';
          break;
        case 3:
          //Film
          filter.start_date = '2013-03-08';
          filter.end_date = '2013-03-16';
          break;
        case 4:
          //Music
          filter.start_date = '2013-03-12';
          filter.end_date = '2013-03-17';
          break;
      }
      updateViewFromFilter();
    }
  });

  // onclick include or exclude categories
  $("#header .filter-inner, #header .advancedbar").on("click", '.tags-menu.ortags.parents .include', function (event) {
    stopPropagation(event);

    var tagID = $(this).attr('tag-id');

    // ******** OR tags stuff **********

    //remove all child categories from included_tags
    for (var i in tags[tagID]["child_ids"]) {
      popFilterTag(tags[tagID]["child_ids"][i]);
    }

    //toggle categories in included_tags
    if ($(this).hasClass('selected')) {
      popFilterTag(tagID);
    } else {
      pushFilterTag(tagID);
    }

    // var tagString = "";
    // for(var i in filter.included_tags) {
    //   tagString += tags[filter.included_tags[i]]["name"] + ",";
    // }
    // console.log(tagString);

    reloadTagsList = false;
    updateViewFromFilter();
  });

  // Do other stuff for children categories in the bar
  $("#header .filter-inner, #header .advancedbar").on("click", '.tags-menu.ortags.children .include', function (event) {

    event.stopPropagation();

    var tagID = $(this).attr('tag-id');

    // if this is selected
    if ($(this).hasClass('selected')) {
      var parent_id = tags[tagID]["parent_id"];
      var parent_tag = tags[parent_id];
      // if the parent is in included_tags
      if (inFilterTag(parent_id)) {
        // then remove the parent category from included_tags
        popFilterTag(parent_id);

        // ***** SXSW if else tags handing. Remove and pull out else contents for regular
        if ((tagID == 191) || (tagID == 189) || (tagID == 184) || (tagID == 167) || (tagID == 166) || (tagID == 165)) {
          pushFilterTag("191");
          pushFilterTag("189");
          pushFilterTag("184");
          pushFilterTag("167");
          pushFilterTag("166");
          pushFilterTag("165");
        } else {
          // and add all the parent's child tags to included_tags
          for (var i in parent_tag["child_ids"]) {
            pushFilterTag(parent_tag["child_ids"][i]);
          }
        }

        // and remove the category from included_tags
        // console.log("About to pop:");
        // console.log(tagID);
        // console.log(filter.included_tags);
        popFilterTag(tagID);
        // console.log(filter.included_tags);
      } else {  // otherwise just remove the tag from included_tags 
        popFilterTag(tagID);
      }
      // if this isn't selected
    } else {
      // add the category to included_tags
      pushFilterTag(tagID);
      var tmpd;
      var parent_id = tags[tagID]["parent_id"];
      var parent_tag = tags[parent_id];
      var allChildrenInFilterTag = true;
      for (var i in parent_tag["child_ids"]) {
        if (!inFilterTag(parent_tag["child_ids"][i])) {
          allChildrenInFilterTag = false;
          break;
        }
      }
      // if all of the category's parent's child tags are in included_tags
      if (allChildrenInFilterTag) {
        // then remove all the child category from included_tags
        // and add the parent category to included_tags
        for (var i in parent_tag["child_ids"]) {
          popFilterTag(parent_tag["child_ids"][i]);
        }
        pushFilterTag(parent_id);
      }
    }

    var tagString = "";
    for (var i in filter.included_tags) {
      tagString += tags[filter.included_tags[i]]["name"] + ",";
    }
    console.log("Filter tags!");
    console.log(filter.exclude_tags);
    if (filter.excluded_tags != "") {
      tagString += " excluding ";
      for (var i in filter.excluded_tags) {
        tagString += tags[filter.excluded_tags[i]]["name"] + ",";
      }
    }
    console.log(tagString);

    reloadTagsList = false;
    updateViewFromFilter();
  });

  // onclick for removing categories when they're clicked in the tag display box
  $("#header .filter-inner, #header .advancedbar").on("click", ".tags-display.ortags .tag", function () {

    var tagID = $(this).attr('tag-id');

    //remove this category from included_tags
    popFilterTag(tagID);

    //remove this category's child categories from included_tags
    for (var i in tags[tagID]["child_ids"]) {
      popFilterTag(tags[tagID]["child_ids"][i]);
    }

    reloadTagsList = false;
    updateViewFromFilter();
  });

  // accordion for tag menu

  $("#header .filter-inner, #header .advancedbar").on("mouseover", '.tags-menu.ortags.parents .tag-header', function1);
  $("#header .filter-inner, #header .advancedbar").on("click", '.tags-menu.ortags.parents .tag-header', function1);

  function function1() {
    $('.tags-menu.ortags .toggler').removeClass('icon-caret-right').addClass('icon-chevron-right');
    $(this).find('.toggler').addClass('icon-caret-right').removeClass('icon-chevron-right');
    $('.tags-menu.parents li').removeClass('selected');
    $(this).parent().addClass('selected');
    var parentTagID = $(this).attr("tag-id");

    $('.tags-menu.ortags.children li').hide();
    $(".tags-menu.ortags.children li[parent-id='" + parentTagID + "']").show();
  }


  // ********* AND tags stuff ***********

  $("#header .filter-inner, #header .advancedbar").on("click", '.tags-menu.andtags.parents .name', function () {
    $(this).siblings('.include').click();
  });

  // onclick include or exclude tags
  $("#header .filter-inner, #header .advancedbar").on("click", '.tags-menu.andtags.parents .include', function (event) {
    stopPropagation(event);

    var tagID = $(this).attr('tag-id');

    //toggle tag in included_tags
    if ($(this).hasClass('selected')) {
      popFilterTag(tagID, "andtags");
    } else {
      pushFilterTag(tagID, "andtags");
    }

    updateViewFromFilter();
  });

  // onclick for removing tags when they're clicked in the tag display box
  $("#header .filter-inner, #header .advancedbar").on("click", ".tags-display.andtags .tag", function () {

    var tagID = $(this).attr('tag-id');

    //remove this tag from included_tags
    popFilterTag(tagID, "andtags");

    updateViewFromFilter();
  });


  // ******* end tags stuff **************

  $('#header').on('click', '.stream:not(.new, .selected, .bookmark)', function () {

    var streamID = $(this).attr('stream-id') || 0;

    filter = $.extend(true, {}, channelFilters[streamID]);
    updateViewFromFilter(true, {hideSaveSearchButton: true});
  });

  $('.filter-summary').on('click', '.filter', function () {
    if ($(this).hasClass("datetime")) {
      filter.start_date = "";
      filter.end_date = "";
      filter.start_seconds = 0;
      filter.end_seconds = 86400;
      filter.start_days = 0;
      filter.end_days = -1;
      filter.day = [0, 1, 2, 3, 4, 5, 6];
    } else if ($(this).hasClass("price")) {
      filter.low_price = "";
      filter.high_price = "";
    } else if ($(this).hasClass("tags")) {
      filter.included_tags = [];
    } else if ($(this).hasClass("andtags")) {
      filter.and_tags = [];
    } else if ($(this).hasClass("search")) {
      filter.search = "";
    }
    updateViewFromFilter();
  });

  $('.filter.sort .filters').on('click', 'span', function () {
    if ($(this).hasClass('popularity'))
      filter.sort = 0;
    else if ($(this).hasClass('date'))
      filter.sort = 1;

    updateViewFromFilter();
  });


  $(".custom-start").datepicker({
    defaultDate: "+1w",
    changeMonth: true,
    numberOfMonths: 1,
    onSelect: function () {
      filter.low_price = "";
      filter.high_price = ($('#slider-step').val() === MAX_PRICE) ? "" : $('#slider-step').val();
      filter.start_date = $('.custom-start').datepicker("getDate").toString("yyyy-MM-dd") + " " + $('.timepicker').val();
      filter.end_date = $('.custom-end').datepicker("getDate").toString("yyyy-MM-dd");
      tag_id = parseInt($('.active a').attr('tag_id'))
      tag_type = $('.active a').attr('tag_type')
      $("#related_events .main .inline .events").html("<center><img src='/assets/ajax-loader.gif'></center>");
      $("#events .main .inline .events").html("<center><img src='/assets/ajax-loader.gif'></center>");
      $(".total_number").html("<img src='/assets/ajax-loader.gif' style='width:10px;height:10px;'>")
      if (tag_id == 0 && (tag_type == "nil" || tag_type == "undefined")) {
        // alert("search key")
        doneTyping1($('#search-tab .active a').text());
        $('#search_name,#search_name1').html($('.active a').attr('key').replace(/\_/g, " "))
      } else if (tag_id == 0) {
        // alert("only tag type")
        filter.tag_id = tag_id
        filter.tag_type = tag_type
        //alert(JSON.stringify(filter))
        $.get("/search_results", filter)
        $('#search_name,#search_name1').html($('.active a').attr('key').replace(/\_/g, " "))
      } else {
        // alert("only key")
        dropdown_search_events($(this).attr('tag_id'))
        $('#search_name,#search_name1').html($('.active a').attr('key').replace(/\_/g, " "))
      }

    },
    onClose: function (selectedDate) {
      $(".custom-end").datepicker("option", "minDate", selectedDate);
    }
  });
  $(".custom-end").datepicker({
    defaultDate: "+1w",
    changeMonth: true,
    numberOfMonths: 1,

    onSelect: function () {
      filter.low_price = "";
      filter.high_price = ($('#slider-step').val() === MAX_PRICE) ? "" : $('#slider-step').val();
      filter.start_date = $('.custom-start').datepicker("getDate").toString("yyyy-MM-dd") + " " + $('.timepicker').val();

      filter.end_date = $('.custom-end').datepicker("getDate").toString("yyyy-MM-dd");
      tag_id = parseInt($('.active a').attr('tag_id'))
      tag_type = $('.active a').attr('tag_type')
      $("#related_events .main .inline .events").html("<center><img src='/assets/ajax-loader.gif'></center>");
      $("#events .main .inline .events").html("<center><img src='/assets/ajax-loader.gif'></center>");
      $(".total_number").html("<img src='/assets/ajax-loader.gif' style='width:10px;height:10px;'>")
      if (tag_id == 0 && (tag_type == "nil" || tag_type == "undefined")) {
        // alert("search key")
        doneTyping1($('#search-tab .active a').text());
        $('#search_name,#search_name1').html($('.active a').attr('key').replace(/\_/g, " "))
      } else if (tag_id == 0) {
        // alert("only tag type")
        filter.tag_id = tag_id
        filter.tag_type = tag_type
        //alert(JSON.stringify(filter))
        $.get("/search_results", filter)
        $('#search_name,#search_name1').html($('.active a').attr('key').replace(/\_/g, " "))
      } else {
        // alert("only key")
        dropdown_search_events($(this).attr('tag_id'))
        $('#search_name,#search_name1').html($('.active a').attr('key').replace(/\_/g, " "))
      }

    },
    onClose: function (selectedDate) {
      $(".custom-start").datepicker("option", "maxDate", selectedDate);

    }

  });
  $(".custom-start,.custom-end").datepicker("setDate", Date.today().toString("MM/dd/yyyy"))

  $( "#slider-step" ).bind( "change", function(event, ui) {
    console.log($(this).val());
    $( "label.cvalue" ).text( 'Less Than $' + $(this).val() );
    filter.low_price = "";
    filter.high_price = ($(this).val() === MAX_PRICE) ? "" : $(this).val();
    filter.start_date = $('.custom-start').datepicker("getDate").toString("yyyy-MM-dd") + " " + $('.timepicker').val();

    filter.end_date = $('.custom-end').datepicker("getDate").toString("yyyy-MM-dd");
    tag_id = parseInt($('.active a').attr('tag_id'))
    tag_type = $('.active a').attr('tag_type')
    $("#related_events .main .inline .events").html("<center><img src='/assets/ajax-loader.gif'></center>");
    $("#events .main .inline .events").html("<center><img src='/assets/ajax-loader.gif'></center>");
    $(".total_number").html("<img src='/assets/ajax-loader.gif' style='width:10px;height:10px;'>")
    if (tag_id == 0 && (tag_type == "nil" || tag_type == "undefined")) {
      // alert("search key")
      doneTyping1($('#search-tab .active a').text());
      $('#search_name,#search_name1').html($('.active a').attr('key').replace(/\_/g, " "))
    } else if (tag_id == 0) {
      // alert("only tag type")
      filter.tag_id = tag_id
      filter.tag_type = tag_type
      //alert(JSON.stringify(filter))
      $.get("/search_results", filter)
      $('#search_name,#search_name1').html($('.active a').attr('key').replace(/\_/g, " "))
    } else {
      // alert("only key")
      dropdown_search_events($(this).attr('tag_id'))
      $('#search_name,#search_name1').html($('.active a').attr('key').replace(/\_/g, " "))
    }

  });


  $(".price-range").slider({
    range: "min",
    min: 0,
    step: 5,
    grid: 5,
    max: MAX_PRICE,
    value: MAX_PRICE,
    slide: function (event, ui) {

      filter.low_price = "";
      filter.high_price = (ui.value === MAX_PRICE) ? "" : ui.value;
      updateViewFromFilter(false);
    },
    stop: updateViewFromFilter
  });

  $(".price-free-button").click(function () {
    filter.high_price = 0;
    updateViewFromFilter();
  });

  $(".time-range").slider({
    range: true,
    min: 0,
    max: MAX_HOURS,
    values: [ 0, MAX_HOURS ],
    slide: function (event, ui) {
      if (ui.values[0] === ui.values[1])
        return false;

      filter.start_seconds = (ui.values[0] === 0) ? "" : ui.values[0] * 3600;
      filter.end_seconds = (ui.values[1] === MAX_HOURS) ? MAX_SECONDS : ui.values[1] * 3600;
      updateViewFromFilter(false);
    },
    stop: updateViewFromFilter
  });

  $('.day-of-week > div').click(function () {
    var index = parseInt($(this).attr('day-of-week'));
    if (filter.day.length == 7) {
      filter.day = [index];
    } else {
      if (filter.day.indexOf(index) == -1) {
        filter.day.push(index);
      } else {
        filter.day.splice(filter.day.indexOf(index), 1);
      }
    }

    if (filter.day.length == 0) {
      filter.day = [0, 1, 2, 3, 4, 5, 6];
    }

    filter.day.sort();
    updateViewFromFilter();
  });

  $('.filter.date .filters span').click(function () {
    filter.start_days = 0;
    filter.end_days = -1;
    filter.day = [0, 1, 2, 3, 4, 5, 6];
    filter.start_date = "";
    filter.end_date = "";


    switch ($(this).index()) {
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
        $('.selected[day-of-week]').each(function () {
          filterDays.push(parseInt($(this).attr('day-of-week')));
        });
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

  $('#unnecessarily-long-id-for-toggling-search-on-map-move-and-zoom').click(function () {
    updateBoundsFlag = $(this).prop("checked");
  });

  //on keyup, start the countdown
  var timer_is_on = 0
  //on keyup, start the countdown

  $('.search-input').keyup(function () {

    $(".active").attr('class', '');
    if (!timer_is_on) {
      timer_is_on = 2;
      if ($(this).val().length >= 3) {
        $(".total_number").html("<img src='/assets/ajax-loader.gif' style='width:10px;height:10px;'>")
        $(window).load(function () {
          $('#releated_events').show()
        })
        console.log("keyup");
        typingTimer = setTimeout(doneTyping1($(this).val()), doneTypingInterval);
        console.log("typing timer is " + typingTimer)
      }
    }

    $('#search_name,#search_name1').text($(this).val())
  });

  //on keydown, clear the countdown
  $('.search-input').keydown(function () {

    console.log("keydown");
    clearTimeout(typingTimer);
    timer_is_on = 0
    console.log("key down" + typingTimer)
  });


  var slideTime = 0;
  $('.filter-toggle:not(.search):not(.filter-action) #filter-text2').click(function (event) {
    var thisToggle = $(this).parents('.filter-toggle');
    console.log(thisToggle + "---------------->this toggle")
    var otherToggled = thisToggle.siblings('.filter-toggle.selected');
    console.log(otherToggled + "---------------->other toggle")
    otherToggled.find('#filter-toggle12').slideUp(slideTime, function () {
      console.log("one")
      otherToggled.removeClass('selected');
    });
    if (thisToggle.hasClass('selected')) {
      console.log("two")
      // $('#header').removeClass('selected');
      thisToggle.find('#filter-toggle2').slideUp(slideTime, function () {
        thisToggle.removeClass('selected');
      });
    } else {
      console.log("three")
      // $('#header').addClass('selected');
      thisToggle.addClass('selected');
      thisToggle.find('#filter-toggle2').slideDown(slideTime);
    }
  });


  $('.filter-toggle:not(.search):not(.filter-action) #filter-text1').click(function (event) {
    var thisToggle = $(this).parents('.filter-toggle');
    console.log(thisToggle + "---------------->this toggle")
    var otherToggled = thisToggle.siblings('.filter-toggle.selected');
    console.log(otherToggled + "---------------->other toggle")
    otherToggled.find('#filter-toggle11').slideUp(slideTime, function () {
      console.log("one")
      otherToggled.removeClass('selected');
    });
    if (thisToggle.hasClass('selected')) {
      console.log("two")
      // $('#header').removeClass('selected');
      thisToggle.find('#filter-toggle1').slideUp(slideTime, function () {
        thisToggle.removeClass('selected');
      });
    } else {
      console.log("three")
      // $('#header').addClass('selected');
      thisToggle.addClass('selected');
      thisToggle.find('#filter-toggle1').slideDown(slideTime);
    }
  });

  $('.filter-toggle:not(.filter-action)').click(function (event) {
    stopPropagation(event);
  });

  $('#ui-datepicker-div').click(function (event) {
    stopPropagation(event);
  });

  $('html').click(function () {
    $('#filter-toggle2,#filter-toggle1').hide()
  });

  $('.filter-action.action-clear').click(function () {
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
  // filter.offset = 0;

  //if filter.changed, show save search button
  //otherwise, hide save search button

  if (options.hideSaveSearchButton === true) {
    $('.filter-action.action-save').hide();
  } else if (options.showSaveSearchButton !== false) {
    $('.filter-action.action-save').show();
  }

  option_day = 0;
  if (filter.start_date !== "" || filter.end_date !== "") {
    option_day = O_CUSTOM;
  } else if (filter.start_days === 0 && filter.end_days === 6) {
    option_day = O_THISWEEK;
  } else if (filter.start_days === 0 && filter.end_days === -1) {
    option_day = O_ANYDAY;
  } else if (filter.start_days === 0 && filter.end_days === 0) {
    option_day = O_TODAY;
  } else {
    console.log(filter);
    console.log("option_day assignment error");
  }

  //tags header
  var filterText = "";

  $('.include').removeClass('selected').removeClass('icon-check').addClass('icon-check-empty');

  for (var i in filter.included_tags) {
    $('.include[tag-id=' + filter.included_tags[i] + ']').addClass('selected').addClass('icon-check').removeClass('icon-check-empty');
    $('[parent-id=' + filter.included_tags[i] + '] .include').addClass('selected').addClass('icon-check').removeClass('icon-check-empty');
    var parent_id = tags[filter.included_tags[i]]["parent_id"];
    if (parent_id) {
      if (!inFilterTag(parent_id)) {
        $('.include[tag-id=' + parent_id + ']').addClass('selected').addClass('icon-check').removeClass('icon-check-empty');
      }
    }
  }

  for (var i in filter.and_tags) {
    $('.include[tag-id=' + filter.and_tags[i] + ']').addClass('selected').addClass('icon-check').removeClass('icon-check-empty');
    $('[parent-id=' + filter.and_tags[i] + '] .include').addClass('selected').addClass('icon-check').removeClass('icon-check-empty');
    var parent_id = tags[filter.and_tags[i]]["parent_id"];
    if (parent_id) {
      if (!inFilterTag(parent_id, "andtags")) {
        $('.include[tag-id=' + parent_id + ']').addClass('selected').addClass('icon-check').removeClass('icon-check-empty');
      }
    }
  }


  var filterTextArr = [];
  var tagDisplayArr = [];


  var andtagsFilterText = "";
  var andtagsFilterTextArr = [];
  var andtagsDisplayArr = [];

  $('.tags-menu.ortags.parents .tag-header').each(function () {
    //get list of parent tags in same order of appearance on page and iterate
    var parent_id = $(this).attr('tag-id');
    var parent_tag = tags[parent_id];

    if (inFilterTag(parent_id)) {
      //if parent is in included_tags print out parent's name
      filterTextArr.push(parent_tag["name"]);
      tagDisplayArr.push({id: parent_id, name: parent_tag["name"]});
    } else {
      //otherwise find intersection of parent's children and included_tags
      var included_child_ids = _.intersection(parent_tag["child_ids"], filter.included_tags);

      if (included_child_ids.length < 4) {
        //if size of intersection is <4 print out child tags' names
        for (var i in included_child_ids) {
          filterTextArr.push(tags[included_child_ids[i]]["name"]);
          tagDisplayArr.push({id: included_child_ids[i], name: tags[included_child_ids[i]]["name"]});
        }
      } else if (included_child_ids.length === parent_tag["child_ids"].length - 1) {
        //otherwise if size of intersection =n-1 print out "[parent](except [missing child])"
        var orphan_id = _.difference(parent_tag["child_ids"], included_child_ids);
        filterTextArr.push(parent_tag["name"] + " (except " + tags[orphan_id]["name"] + ")");
        tagDisplayArr.push({id: parent_id, name: parent_tag["name"] + " (except " + tags[orphan_id]["name"] + ")"});
      } else {
        //otherwise print out "[size] [parent name] tags"
        filterTextArr.push(included_child_ids.length + " " + parent_tag["name"] + " Tags");
        tagDisplayArr.push({id: parent_id, name: included_child_ids.length + " " + parent_tag["name"] + " Tags"});
      }
    }
  });

  $('.tags-menu.andtags.parents .tag-header').each(function () {

    //get list of parent tags in same order of appearance on page and iterate
    var parent_id = $(this).attr('tag-id');
    var parent_tag = tags[parent_id];


    if (inFilterTag(parent_id, "andtags")) {
      // console.log("tag: " + parent_tag["name"]);
      //if parent is in included_tags print out parent's name
      andtagsFilterTextArr.push(parent_tag["name"]);
      andtagsDisplayArr.push({id: parent_id, name: parent_tag["name"]});
    }
  });

  andtagsFilterText = andtagsFilterTextArr.join(" and ");

  filterText = filterTextArr.join("/");

  if (filterText === "")
    filterText = ANY_CATEGORY_TEXT;

  if (andtagsFilterText === "")
    andtagsFilterText = ANY_TAG_TEXT;

  $('.filter-toggle.tags.ortags .text-inner').html(filterText);

  $('.filter-toggle.tags.andtags .text-inner').html(andtagsFilterText);

  //categories selection
  $('.tags-display.ortags').empty();
  for (var i in tagDisplayArr) {
    $('.tags-display.ortags').append("<span class='tag included' tag-id='" + tagDisplayArr[i]["id"] + "'><span class='include icon-check'></span><span class='name'>" + tagDisplayArr[i]["name"] + "</span></span>");
  }

  //tags selection
  $('.tags-display.andtags').empty();
  for (var i in andtagsDisplayArr) {
    $('.tags-display.andtags').append("<span class='tag included' tag-id='" + andtagsDisplayArr[i]["id"] + "'><span class='include icon-check'></span><span class='name'>" + andtagsDisplayArr[i]["name"] + "</span></span>");
  }

  ////////////// DATETIME //////////////

  $('.filter.date .filters span').removeClass('selected');
  $('.filter.date .filters span:nth-child(' + (option_day + 1) + ')').addClass('selected');

  $('.filter.date .custom-select').removeClass('selected');
  $('.filter.date .custom-select:nth-child(' + (option_day + 1) + ')').addClass('selected');

  //time
  var start_hours = (filter.start_seconds === "") ? 0 : filter.start_seconds / 3600;
  var end_hours = (filter.end_seconds === "") ? MAX_HOURS : filter.end_seconds / 3600;

  $(".custom-select:nth-child(" + (option_day + 1) + ") .time-range").slider("values", 0, start_hours);
  $(".custom-select:nth-child(" + (option_day + 1) + ") .time-range").slider("values", 1, end_hours);

  //time string
  var timeStr = "";
  var timePreStr = "";
  if (start_hours === 0 && end_hours === MAX_HOURS) {
    timeStr = ANY_TIME_TEXT;
  } else {
    if (end_hours === MAX_HOURS) {
      timeStr = "<em>" + hours[start_hours] + "</em>";
      timePreStr = "after ";
    } else if (start_hours === 0) {
      timeStr = "<em>" + hours[end_hours] + "</em>";
      timePreStr = "before ";
    } else {
      var timeOne = hours[start_hours];
      var timeTwo = hours[end_hours];
      timeStr = "<em>" + timeOne + "&ndash;" + timeTwo + "</em>";
      timePreStr = "";
    }
  }

  $(".custom-select:nth-child(" + (option_day + 1) + ") .time-display").html(timePreStr + " " + timeStr);

  //date
  if (filter.start_date !== "") {
    console.log(filter.start_date);
    var parsedDate = $.datepicker.parseDate('yy-mm-dd', filter.start_date);
    $('.custom-start').datepicker("setDate", parsedDate);
  }
  if (filter.end_date !== "") {
    console.log(filter.end_date);
    var parsedDate = $.datepicker.parseDate('yy-mm-dd', filter.end_date);
    $('.custom-end').datepicker("setDate", parsedDate);
  }

  var dateStr = "";
  var datePreStr = "during ";
  var dow_short = ['Su', 'M', 'T', 'W', 'Th', 'F', 'Sa'];
  var dow_medium = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  var dow_long = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
  if (option_day === O_ANYDAY) {
    dateStr = "";
  } else if (option_day === O_TODAY) {
    datePreStr = "";
    dateStr = "Today";
  } else if (option_day === O_THISWEEK) {
    if (filter.day.length === 7) {
      datePreStr = "";
      dateStr = "This Week";
    } else {
      var num_days = filter.day.length;
      for (var i in filter.day) {
        if (num_days === 1) {
          dateStr += "+" + dow_long[filter.day[i]];
        } else if (num_days === 2) {
          dateStr += "+" + dow_medium[filter.day[i]];
        } else {
          dateStr += "/" + dow_short[filter.day[i]];
        }
      }
      dateStr = dateStr.substring(1);
    }
  } else if (option_day === O_CUSTOM) {
    dateStr = $('.custom-start').datepicker("getDate").toString("MM/dd") + "&ndash;" + $('.custom-end').datepicker("getDate").toString("MM/dd")
  }

  var titleStr = "";
  var titlePreStr = "";
  if (dateStr === "") {
    titleStr = timePreStr + timeStr;
  } else {
    titlePreStr = datePreStr;
    if (timeStr === ANY_TIME_TEXT) {
      titleStr = dateStr;
    } else {
      titleStr = dateStr + " " + timePreStr + timeStr;
    }
  }

  $('.day-of-week > div').removeClass('selected');
  for (var i in filter.day) {
    $('.day-of-week > div[day-of-week=' + filter.day[i] + ']').addClass('selected');
  }

  //$('.filter-toggle.date .pre-text').html(titlePreStr);
  $('.filter-toggle.date .text-inner').html(titleStr);

  ////////////// PRICE //////////////
0
  var low_price = (filter.low_price === "") ? 0 : filter.low_price;
  var high_price = (filter.high_price === "") ? MAX_PRICE : filter.high_price;

  //price selection and header
  $(".price-range").slider("value", high_price);
  //$(".price-range").slider("values", 1, high_price);

  var priceStr;
  if (low_price === 0 && high_price >= MAX_PRICE) {
    priceStr = ANY_PRICE_TEXT;
  } else {
    if (high_price >= MAX_PRICE) {
      priceStr = "Over $" + low_price;
    } else if (low_price === high_price) {
      priceStr = (low_price === 0 ? "Free" : "$" + low_price);
    } else if (low_price === 0) {
      priceStr = "Under $" + high_price;
    } else {
      var priceOne = "$" + low_price;
      var priceTwo = "$" + high_price;
      priceStr = priceOne + " - " + priceTwo;
    }
  }

  if (high_price === 0) {
    $('.price-free-button').addClass('isFree');
  } else {
    $('.price-free-button').removeClass('isFree');
  }

  $('.price-display, .filter-toggle.price .text-inner').html(priceStr);

  ////////////// SORT //////////////

  //sort
  var sortStr = "";
  $('.filter.sort .filters span').removeClass('selected');
  if (filter.sort === 0) {
    $('.filter.sort .filters span.popularity').addClass('selected');
    sortStr = "Most Views";
  } else if (filter.sort === 1) {
    $('.filter.sort .filters span.date').addClass('selected');
    sortStr = "Date";
  }
  $('.filter-toggle.sort .text-inner').html(sortStr);

  ////////////// SEARCH //////////////

  if (!(options.update_search === false)) {
    $('.search-input').val(filter.search);
  }

  ////////////// FILTER SUMMARY //////////////

  if (titleStr === ANY_TIME_TEXT) {
    $('.filter-summary .datetime').hide();
    $('.filter-summary .datetime').html("");
  } else {
    $('.filter-summary .datetime').html(titlePreStr + titleStr);
    $('.filter-summary .datetime').show();
  }

  if (priceStr === ANY_PRICE_TEXT) {
    $('.filter-summary .price').hide();
    $('.filter-summary .price').html("");
  } else {
    $('.filter-summary .price').html(priceStr);
    $('.filter-summary .price').show();
  }

  if (filterText === ANY_CATEGORY_TEXT) {
    $('.filter-summary .tags').hide();
    $('.filter-summary .tags').html("");
  } else {
    $('.filter-summary .tags').html(filterText);
    $('.filter-summary .tags').show();
  }

  if (andtagsFilterText === ANY_TAG_TEXT) {
    $('.filter-summary .andtags').hide();
    $('.filter-summary .andtags').html("");
  } else {
    $('.filter-summary .andtags').html(andtagsFilterText);
    $('.filter-summary .andtags').show();
  }

  if (filter.search === "") {
    $('.filter-summary .search').hide();
    $('.filter-summary .search').html("");
  } else {
    $('.filter-summary .search').html("&lsquo;" + filter.search + "&rsquo;");
    $('.filter-summary .search').show();
  }

  if (pullEventsFlag) {
    pullEvents();
  }
  // console.log("XXXXXX Update filter XXXXXXXX");
}

function streamSelector() {
  $('#dk_container_stream-select').remove();
  $('.streambar .stream.selector').remove();

  var parentWidth = $('.streambar .header').width() - $('.action-save').outerWidth(true) - $('.filter-toggle.sort').outerWidth(true);
  /* - $('.action-bookmarks').outerWidth(true) -  - $('.action-clear').outerWidth(true)*/
  ; //- $('.stream.new').width();
  var sumWidth = 0;
  var maxWidth = 0;
  var overflowIndex = 0;
  // dropdown creator
  $('.streambar .header .stream').each(function (index) {

    sumWidth += $(this).outerWidth(true);

    // console.log("[" + index + "] " + $(this).text() + ":");
    // console.log("width: " + $(this).outerWidth(true));
    // console.log("sumWidth: " + sumWidth);
    // console.log("parentwidth: " + parentWidth);   
    // console.log("");

    if (sumWidth > parentWidth && overflowIndex === 0) {
      overflowIndex = index;
    }

    if (overflowIndex != 0) {
      maxWidth = Math.max(maxWidth, $(this).outerWidth(true) + 36);
    }
  });

  // console.log("overflowIndex: " + overflowIndex);
  // console.log("");

  //if there are overflowed streams, make a stream dropdown
  if (overflowIndex != 0) {
    var streamSelect = $("<select name='stream-select' class='stream selector' style='position:absolute;top:0;right:0;'></select>");
    sumWidth = 0;
    $('.streambar .stream').each(function (index) {
      sumWidth += $(this).outerWidth(true);
      // console.log($(this).text() + ":");
      // console.log("width: " + $(this).outerWidth());
      // console.log("sumWidth: " + sumWidth);
      // console.log("parentwidth: " + parentWidth);   
      // console.log("");
      if (index >= overflowIndex || (sumWidth + maxWidth + 24 > parentWidth)) {
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
        console.log("stream selected");
        $("#dk_container_stream-select").addClass('selected');
        // $(".streambar .stream").removeClass('selected');
        // $('#header').addClass('selected');

        var channelID = parseInt(value);
        // console.log("channelID");
        filter = $.extend(true, {}, channelFilters[channelID]);
        // console.log(filter);
        updateViewFromFilter(true, {hideSaveSearchButton: true});
      }
    });
  } else {
    $('.streambar .stream').show();
  }
}

//user is "finished typing," do something
function doneTyping() {
  $('#related_events').show()
  filter.search = $('.search-input').val();
  pullEvents({update_search: false});
}
function doneTyping1(search) {
  filter.search = search;
  pullEvents1({update_search: false, search: "elastic"});

  window.location.hash = "key:" + search;
}

var boundsChangedFlag = false;
var updateBoundsFlag = true;
function boundsChanged() {
  if (updateBoundsFlag) {
    filter.lat_min = map.getBounds().getSouthWest().lat();
    filter.lat_max = map.getBounds().getNorthEast().lat();
    filter.long_min = map.getBounds().getSouthWest().lng();
    filter.long_max = map.getBounds().getNorthEast().lng();
    if (boundsChangedFlag) {
      updateViewFromFilter(true, {showSaveSearchButton: false});
    }
    boundsChangedFlag = true;
  }
}

// this gets called on infinite scroll and on filter changes
function pullEvents(updateOptions) {
  // alert("pullevents")
  $("#related_events .main .inline .events").html("<center><img src='/assets/ajax-loader.gif'></center>");
  $("#events .main .inline .events").html("<center><img src='/assets/ajax-loader.gif'></center>");
  // console.log(filter);

  var async_reloadTagsList = reloadTagsList;
  var async_infiniteScrolling = infiniteScrolling;

  updateOptions = defaultTo(updateOptions, {});

  // console.log("pullEvents");
  // console.log("infiniteScrolling: " + infiniteScrolling);
  // console.log("reloadTagsList: " + reloadTagsList);
  // console.log(filter);

  loading('show');

  var visibleTagListID = $('.tags-menu.ortags.children li:visible').attr('parent-id');
  var controllerLink = "/events/index?ajax=true"
  if (window.location.href.indexOf("sxsw") > -1) {
    controllerLink = "/events/sxsw?ajax=true"
  }

  $.get(controllerLink, filter, function (data) {
    var locations = [];

    var jData = $(data);

    if (async_infiniteScrolling) {
      $('#content .main .inner .events').append(jData.find("#combo_event_list").html());
      infiniteScrolling = false;
    } else {
      //$('.tab-content').append("<div id="+ filter["search"] +" class='tab-pane fade'><div class='content main'><div class='container inline'><section class='product-list clearfix events'></section></div></div></div>")
      console.log($(data).length)

      $("#related_events .main .inline .events").html(data);
      $("#events .main .inline .events").html(data);

      $(".total_number").text($("#related_events .main .inline .events").find('article').length);

//      console.log("----NUM EVENTS-----");
//      console.log(jData.find("#combo_total_occurrences").html());
//      if (jData.find("#combo_total_occurrences").html().indexOf("1000") > 0) {
//        $('.filter-summary .num-events').html(jData.find("#combo_total_occurrences").html() + "+");
//      } else {
//        $('.filter-summary .num-events').html(jData.find("#combo_total_occurrences").html());
//      }
//      if(async_reloadTagsList) {
//        $('#header .filter-toggle.tags.ortags .filter-inner').html(jData.find("#combo_tag_list").html());
//        $('#header .filter-toggle.tags.andtags .filter-inner').html(jData.find("#combo_andtag_list").html());
//        $('#header .advancedbar .tags-list').html(jData.find("#combo_advanced_tag_list").html());
//      } else {
//        reloadTagsList = true;
//      }
//    }
//
//    if(visibleTagListID) {
//      $("li[parent-id='" + visibleTagListID + "']").show();
//      //$('.tag-header[tag-id=' + visibleTagListID + '] .toggler').html("&#x25BC;");
//    }
//
//    $('#content .main .inner .events li').each(function(index) {
//      locations.push({lat: $(this).find('.latitude').html(),
//                     long: $(this).find('.longitude').html()});
//    });
//
//    placeMarkers({points: locations});
//
//    loading('hide');
//
//    updateOptions.showSaveSearchButton = false;
//    updateViewFromFilter(false, updateOptions);
//
//    // gotta jiggle the handle for position:fixed elements on resize, i think? weird.
//    //var top = $('#map-wrapper').position().top;
//    //$('#map-wrapper').css("top",(top + 1) + "px");
//
//    if(!async_infiniteScrolling) {
//      $('#body').scrollTop(Math.min($('#body').scrollTop(),$('#header .one').outerHeight()));
    }
    checkScroll();
    addthisevent.refresh();
    $('figure').click(function () {
      var event_id = $(this).parent('article').attr('link-id')
      console.log(event_id)
      window.location.href = window.location.origin + "/events/austin/" + event_id

    })

  });
}
function pullEvents1(updateOptions, search) {
  //alert("pullevents1")
  $("#related_events .main .inline .events").html("<center><img src='/assets/ajax-loader.gif'></center>");
  $("#events .main .inline .events").html("<center><img src='/assets/ajax-loader.gif'></center>");
  var async_reloadTagsList = reloadTagsList;
  var async_infiniteScrolling = infiniteScrolling;
  updateOptions = defaultTo(updateOptions, {});
  loading('show');
  var visibleTagListID = $('.tags-menu.ortags.children li:visible').attr('parent-id');
  var controllerLink = "/events/index?ajax=true"
  if (window.location.href.indexOf("sxsw") > -1) {
    controllerLink = "/events/sxsw?ajax=true"
  }
  //alert("hi")
  //alert(JSON.stringify(filter))
  filter.query = filter.search
  $.get("/search_results", filter)
}

function tagged_saved_search_events(tag, location) {

  var controllerLink = "/events/index?ajax=true"

  $.get(controllerLink, {"included_tags": tag}, function (data) {
    var locations = [];
    var jData = $(data);
    if (false) {
    } else {
      $("#" + location).html(data);
      slider_arrows(location)
      if ($('#' + location).find('article').length) {
        $('#' + location).append("<article class='slide-item product-item see-more'><a href='/search' class='see-more' ><span class='btn btn-large btn-danger'>See More</span></a></article>")
      }
      $('.before_login').click(function () {
        window.location.href = window.location.origin + "/login"
      })
    }
  });
}
function saved_search_events(location) {
  console.log(location)

  var controllerLink = "/events/index?ajax=true&root=true"
  f1 = {"search": location}
  $.get(controllerLink, f1, function (data) {
    var locations = [];
    var jData = $(data);
    if (false) {
    } else {
      $("#" + location).html(data);
      slider_arrows(location)
      if ($('#' + location).find('article').length) {
        $('#' + location).append("<article class='slide-item product-item see-more'><a href='/search' class='see-more' ><span class='btn btn-large btn-danger'>See More</span></a></article>")
      }
      $('.before_login').click(function () {
        window.location.href = window.location.origin + "/login"
      })
    }
  });

}
function dance_events(dance_tag, location) {
  console.log(location)
  var controllerLink = "/events/index?ajax=true&root=true"
  f1 = {"included_tags": dance_tag}
  $.get(controllerLink, f1, function (data) {
    var locations = [];
    var jData = $(data);
    if (false) {
    } else {
      $("#" + location).html(data);
      slider_arrows(location)
      if ($('#' + location).find('article').length) {
        $('#' + location).append("<article class='slide-item product-item see-more'><a href='/search' class='see-more' ><span class='btn btn-large btn-danger'>See More</span></a></article>")
      }
      $('.before_login').click(function () {
        window.location.href = window.location.origin + "/login"
      })
    }
  });

}
function happy_place_events(stream_id, location) {
  console.log(location)
  var controllerLink = "/events/index?ajax=true&root=true"
  f1 = {"stream_id": stream_id}
  $.get(controllerLink, f1, function (data) {
    var locations = [];
    var jData = $(data);
    if (false) {
    } else {
      $("#" + location).html(data);
      slider_arrows(location)
      if ($('#' + location).find('article').length) {
        $('#' + location).append("<article class='slide-item product-item see-more'><a href='/search' class='see-more' ><span class='btn btn-large btn-danger'>See More</span></a></article>")
      }
      $('.before_login').click(function () {
        window.location.href = window.location.origin + "/login"
      })
    }
  });

}
function free_events(location) {
  console.log(location)
  var controllerLink = "/events/index?ajax=true&root=true"
  f1 = {"high_price": 0}
  $.get(controllerLink, f1, function (data) {
    var locations = [];
    var jData = $(data);
    if (false) {
    } else {
      $("#" + location).html(data);
      slider_arrows(location)
      if ($('#' + location).find('article').length) {
        $('#' + location).append("<article class='slide-item product-item see-more'><a href='/search' class='see-more' ><span class='btn btn-large btn-danger'>See More</span></a></article>")
      }
      $('.before_login').click(function () {
        window.location.href = window.location.origin + "/login"
      })
    }
  });

}
function cost_filter_events(high_price) {
  console.log(high_price)
  var controllerLink = "/events/index?ajax=true&root=true"
  $("#related_events .main .inline .events").html("<center><img src='/assets/ajax-loader.gif'></center>");
  $("#events .main .inline .events").html("<center><img src='/assets/ajax-loader.gif'></center>");
  $(".total_number").html("<img src='/assets/ajax-loader.gif' style='width:10px;height:10px;'>")
  filter.high_price = high_price
  $.get(controllerLink, filter, function (data) {
    var locations = [];
    var jData = $(data);
    if (false) {
    } else {
//      $(".total_number").text($('#'+location).find('article').length)
      $("#related_events .main .inline .events").html(data);
      $("#events .main .inline .events").html(data);
      $(".total_number").text($("#related_events .main .inline .events").find('article').length);

    }
  });
}
function dropdown_search_events(tag) {
  console.log(tag)
  filter.included_tags = tag
  $.get("/events/index?ajax=true", filter, function (data) {
    $("#related_events .main .inline .events").html(data);
    $("#events .main .inline .events").html(data);
    $(".total_number").text($("#related_events .main .inline .events").find('article').length);
  });
}
function slider_arrows(location) {
  $("#" + location).carouFredSel({
    responsive: true,
    infinite: true,
    auto: false,
    prev: {
      button: "#" + location + "_prev",
      key: "left"
    },
    next: {
      button: "#" + location + "_next",
      key: "right"
    },
    swipe: {
      onMouse: true,
      onTouch: true
    },
    scroll: 1,
    items: {
      width: 299,
      height: 375,	//	optionally resize item-height
      visible: {
        min: 1,
        max: 3
      }
    }
  });


  $('figure').click(function () {
    var event_id = $(this).parent('article').attr('link-id')
    console.log(event_id)
    window.location.href = window.location.origin + "/events/austin/" + event_id

  })
}
var pulling = false;
function loading(command) {
  if (command === 'show') {
    pulling = true;
    if (!infiniteScrolling) {
      var top = 100//$('.main .inner .events').scrollTop();
      var bottom = 200//$('.main .inner .events').height() - Math.max(0,$('.main .inner .events').height() + $('.main .inner .events').offset().top - $(window).height() - $(window).scrollTop());
      var y = (top + bottom) / 2 - 33;
      var x = $('.main .inner .events').width() / 2 - 33;
      $('.main .inner .header, .main .inner .events').css('opacity', '.5');
      if (y > 0) {
        $('#loading').css('top', y + 'px');
        $('#loading').css('left', x + 'px');
        $('#loading').show();
      }
    } else {

      // var status = document.getElementById("androidStatus").value;
      if (device !== "mobile") {
        $('#infinite-loader').show();
      }
      ;


    }
  } else if (command === 'hide') {
    $('.main .inner .header, .main .inner .events').css('opacity', '1');
    $('#loading').hide();
    $('#infinite-loader').hide();
    pulling = false;
  }
}

function checkInfinite() {
  //console.log("checkInfinite");
  //if we're near the bottom of the page and not currently pulling in events
  if ($('#body').scrollBottom() < 1000 && !pulling) {
    //console.log("pull em");
    //check if there are any more possible events to pull
    // if so, pull em.
    // var uagent = navigator.userAgent.toLowerCase(); 
    // var device = '';
    // if (uagent.search("iphone") > -1)
    //        device = 'iphone';
    // else if (uagent.search("ipod") > -1)
    //        device = 'ipod';
    // else if (uagent.search("tablet") > -1)
    //        device = 'tablet';
    // else if (uagent.search("ipad") > -1)
    //        device = 'ipad';
    // else if (uagent.search("android") > -1)
    //        device = 'android';

    console.log("Check browser");
    // alert(device);

    if ($('#content .main .inner .events li:not(.no-results)').length < parseInt($('.filter-summary .num-events').html())) {
      infiniteScrolling = true;
      filter.offset = $('#content .main .inner .events li').length;
      // var status = document.getElementById("androidStatus").value;
      if (device !== "mobile") {
        pullEvents();
      }


    }
  }
}

$(function () {
  $('#search-tab a').on("click", function () {
    console.log("i am here")
    tag_id = parseInt($(this).attr('tag_id'))
    tag_type = $(this).attr('tag_type')

    $("#related_events .main .inline .events").html("<center><img src='/assets/ajax-loader.gif'></center>");
    $("#events .main .inline .events").html("<center><img src='/assets/ajax-loader.gif'></center>");
    $(".total_number").html("<img src='/assets/ajax-loader.gif' style='width:10px;height:10px;'>")
    if (tag_id == 0 && (tag_type == "nil" || tag_type == "undefined")) {
      console.log("search key filter")
      doneTyping1($(this).text());
      $('#search_name,#search_name1').html($(this).attr('key').replace(/\_/g, " "))
    } else if (tag_id == 0) {
      console.log("tag type filter")
      filter.tag_id = tag_id
      filter.tag_type = tag_type
      $.get("/search_results", filter)
      $('#search_name,#search_name1').html($(this).attr('key').replace(/\_/g, " "))
    } else {
      console.log('tag_id filter')
      dropdown_search_events($(this).attr('tag_id'))
      $('#search_name,#search_name1').html($(this).attr('key').replace(/\_/g, " "))
    }

  });
});