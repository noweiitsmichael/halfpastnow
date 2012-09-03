/** jquery plugins **/

// checks if element has a scrollbar
$.fn.hasScrollBar = function() {
    return this.get(0).scrollHeight > this.innerHeight();
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

var defaultThing = { url: function() { return "/" + this.type + "s/show/" + this.id; } };

var things = {
  "venue": spawn(defaultThing,{type: "venue"}),
  "event": spawn(defaultThing,{type: "event"}),
  "act": spawn(defaultThing,{type: "act"}),
  "shunt": spawn(defaultThing,{type: "shunt", url: function() { return "/events/shunt"; }})
};

var mapOffset;

var hours = ['midnight','1am','2am','3am','4am','5am','6am','7am','8am','9am','10am','11am','noon','1pm','2pm','3pm','4pm','5pm','6pm','7pm','8pm','9pm','10pm','11pm','midnight'];

var MAX_DAYS = 30;
var MAX_PRICE = 50;
var MAX_HOURS = 24;
var MAX_SECONDS = 86400;
var ANY_TIME_TEXT = "Any Time";

var filter = {
  option_day: 0,
  start_days: "",
  end_days: "",
  start_seconds: "",
  end_seconds: "",
  day: [0,1,2,3,4,5,6],
  low_price: "",
  high_price: "",
  included_tags: [],
  excluded_tags: [],
  lat_min: "",
  lat_max: "",
  long_min: "",
  long_max: "",
  offset: 0,
  search: "",
  sort: 0,
  name: ""
};

$(function() {
  channelFilters[0] = $.extend(true, {}, filter);
  //console.log(filter);

  scrollbarWidth = $.getScrollbarWidth();

  // onclick include or exclude tags
  $("#header .filter-inner, #header .advancedbar").on("click", '.tags-menu .include, .tags-menu .exclude', function() {
    //turn off if already selected
    if($(this).hasClass('selected')) {
      $('.tags-display .tag[tag-id=' + $(this).attr('tag-id') + ']').click();
      return;
    }

    var include = $(this).hasClass('include');
    var tagID = $(this).attr('tag-id');

    if(include && filter.included_tags.indexOf(tagID) === -1) {
      filter.included_tags.push(tagID);
      var excludedIndex = filter.excluded_tags.indexOf(tagID);
      if(excludedIndex !== -1) {
        filter.excluded_tags.splice(excludedIndex,1);
      }
    } else if(!include && filter.excluded_tags.indexOf(tagID) === -1) {
      filter.excluded_tags.push(tagID);
      var includedIndex = filter.included_tags.indexOf(tagID);
      if(includedIndex !== -1) {
        filter.included_tags.splice(includedIndex,1);
      }
    }

    updateViewFromFilter();
  });

  // onclick for removing tags when they're clicked in the tag display box
  $("#header .filter-inner, #header .advancedbar").on("click", ".tags-display .tag", function() {
    var included = $(this).hasClass('included');
    var tagID = $(this).attr('tag-id');

    if(included)
      filter.included_tags.splice(filter.included_tags.indexOf(tagID),1);
    else
      filter.excluded_tags.splice(filter.excluded_tags.indexOf(tagID),1);

    updateViewFromFilter();
  });

  // accordion for tag menu

  $("#header .filter-inner, #header .advancedbar").on("click", '.tags-menu .toggler, .tags-menu .tag-header .name', function() {
    $(this).parent().parent().siblings().find('.toggler').html("&#x25B6;");
    $(this).parent().parent().siblings().find('ul').slideUp();
    var childTagList = $(this).parent().parent().find('ul');
    if(childTagList.is(":visible")) {
      $(this).parent().find('.toggler').html("&#x25B6;");
    } else {
      $(this).parent().find('.toggler').html("&#x25BC;");
    }
    childTagList.slideToggle();
  });

  
  $('.lists li').not('.no-select').click(function() {
    var index = $(this).index() + 1;
    $('.lists li').removeClass('selected');
    $('.lists li:nth-child(' + index + ')').addClass('selected');
    
    var channelID = $(this).attr('channel-id') || 0;
    filter = $.extend(true, {}, channelFilters[channelID]);

    updateViewFromFilter();
  });

  $('.sorts li').not('.no-select').click(function() {    
    filter.sort = $(this).index();
    
    updateViewFromFilter();
  });

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

  $(".date-range").slider({
    //range: true,
    min: 0,
    max: MAX_DAYS,
    //values: [ 0, MAX_DAYS ],
    value: 0,
    slide: function( event, ui ) {
      //if (ui.values[0] === MAX_DAYS)
      //  return false;

      filter.start_days = ui.value;
      filter.end_days = ui.value;

      //filter.start_days = ui.values[0];
      //filter.end_days = ui.values[1];
      updateViewFromFilter(false);
    },
    stop: updateViewFromFilter
  });

  $('.filter.date .filters span').click(function () {
    filter.option_day = $(this).index();

    switch(filter.option_day) {
      case 0:
        filter.start_days = "";
        break;
      case 1:
        filter.start_days = 0;
        break;
      case 2:
        filter.start_days = 1;
        break;
      case 3:
        filter.start_days = $(".date-range").slider("value");
        break;
    }
    filter.end_days = filter.start_days;
    
    updateViewFromFilter();
  });
});

function defaultTo(parameter, parameterDefault) {
  return (typeof parameter !== 'undefined') ? parameter : parameterDefault;
}

function updateViewFromFilter(pullEventsFlag) {
  pullEventsFlag = defaultTo(pullEventsFlag, true);

  //console.log("filter: ");
  //console.log(filter);
  //console.log(channelFilters);

  ////////////// CHANNELS //////////////

  var channelStr = filter.name === "" ? "All Events" : filter.name;
  $('.filter-toggle.channels .text-inner').html(channelStr);

  ////////////// TAGS ////////////// 

  $('.tags-display').empty();

  //tags selection
  for(var i in filter.included_tags) {
    $('.tags-display').append("<span class='tag included' tag-id='" + filter.included_tags[i] + "'><span class='name'>" + tags[filter.included_tags[i]] + "</span><span class='remove'>&#10799;</span></span>");
  }

  for(var i in filter.excluded_tags) {
    $('.tags-display').append("<span class='tag excluded' tag-id='" + filter.excluded_tags[i] + "'><span class='name'>" + tags[filter.excluded_tags[i]] + "</span><span class='remove'>&#10799;</span></span>");
  }

  //tags header
  var filterText = "";
  
  $('.include').removeClass('selected');
  for(var i in filter.included_tags) {
    filterText += tags[filter.included_tags[i]];
    if(i < filter.included_tags.length - 1 || filter.excluded_tags.length !== 0)
      filterText += " + ";
    $('.include[tag-id='+filter.included_tags[i]+']').addClass('selected');
  }

  $('.exclude').removeClass('selected');
  for(var i in filter.excluded_tags) {
    filterText += "<em>not</em> " + tags[filter.excluded_tags[i]];
    if(i < filter.excluded_tags.length - 1)
      filterText += " + ";
    $('.exclude[tag-id='+filter.excluded_tags[i]+']').addClass('selected');
  }

  if (filterText === "")
    filterText = "Any Tag";

  $('.filter-toggle.tags .text-inner').html(filterText);

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

  var timeStr = "";
  var timePreStr = "at ";
  if(start_hours === 0 && end_hours === MAX_HOURS) {
    timeStr = ANY_TIME_TEXT;
  } else {
    if(end_hours === MAX_HOURS) {
      timeStr = hours[start_hours];
      timePreStr = "after ";
    } else if(start_hours === 0) {
      timeStr = hours[end_hours];
      timePreStr = "before ";
    } else {       
      var timeOne = hours[start_hours];
      var timeTwo = hours[end_hours];
      timeStr = timeOne + "&ndash;" + timeTwo;
      timePreStr = "from ";
    }
  }

  $(".custom-select:nth-child(" + (filter.option_day + 1) +  ") .time-display").html(timePreStr + " " + timeStr);
  
  //date

  //$(".date-range").slider("values", 0, filter.start_days);
  //$(".date-range").slider("values", 1, filter.end_days);

  // var dateMod = function (dateVal) {
  //   if(dateVal === 0)
  //     return "today";
  //   if(dateVal === 1)
  //     return "tomorrow";
  //   if(dateVal === MAX_DAYS)
  //     return "forever";
  //   if(dateVal < 7)
  //     return "This " + Date.today().add(dateVal).days().toString("dddd");
  //   if(dateVal < 14)
  //     return "Next " + Date.today().add(dateVal).days().toString("dddd");
    
  //   return Date.today().add(dateVal).days().toString("MMM d");
  // };

  // var dateStr;
  // if(filter.start_days === 0 && filter.end_days >= MAX_DAYS) {
  //   dateStr = "Any Date";
  // } else {
  //   if(filter.end_days >= MAX_DAYS) {
  //     dateStr = "After " + dateMod(filter.start_days - 1);
  //   } else if(filter.start_days === filter.end_days) {
  //     dateStr = dateMod(filter.start_days);
  //   } else if(filter.start_days === 0) {
  //     dateStr = "Before " + dateMod(filter.end_days + 1);
  //   } else {
  //     var dateOne = dateMod(filter.start_days);
  //     var dateTwo = dateMod(filter.end_days);
  //     dateStr = dateOne + " - " + dateTwo;
  //   }
  // }

  $(".date-range").slider("value", filter.start_days);

  var dateStr = "";
  var datePreStr = "during ";
  if(filter.option_day === 0)
    dateStr = "";
  else if(filter.start_days === 0)
    dateStr = "Today";
  else if(filter.start_days === 1)
    dateStr = "Tomorrow";
  else if(filter.start_days < 7)
    dateStr = Date.today().add(filter.start_days).days().toString("dddd");
  else if(filter.start_days < 14)
    dateStr = "Next " + Date.today().add(filter.start_days).days().toString("ddd");
  else
    dateStr = Date.today().add(filter.start_days).days().toString("MMM d");

  if(filter.option_day === 3)
    $(".date-display").html(dateStr);

  var titleStr = "";
  var titlePreStr = "";
  if(dateStr === "") {
    titleStr = timeStr;
    if(timePreStr !== "") {
      titlePreStr = timePreStr;
    }
  } else {
    titlePreStr = datePreStr;
    if(timeStr === ANY_TIME_TEXT) {
      titleStr = dateStr;
    } else {
      titleStr = dateStr + " " + timePreStr + timeStr;
    }
  }

  $('.filter-toggle.date .pre-text').html(titlePreStr);
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
  $('.sorts li').removeClass('selected');
  $('.sorts li:nth-child(' + (filter.sort + 1) + ')').addClass('selected');
  
  //sort header
  $('.filter-toggle.sort .text-inner').html($('.sorts li.selected').html());

  //search terms [later]

  if(pullEventsFlag) {
    pullEvents();
  }
}


var advancedSlideTime, filterSlideTime, marginHeight, baseHeight, filterHeight, advancedHeight;

$(function() {
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

  $('#content').on("mouseenter", ".events li", function() {
    google.maps.event.trigger(markers[$(this).index()], 'mouseover');
  });

  $('#content').on("mouseleave", ".events li", function() {
    google.maps.event.trigger(markers[$(this).index()], 'mouseout');
  });

  $('#body').scroll(showPageMarkers);
  $('#body').scroll(lockMap);
  
  $(window).resize(showPageMarkers);
  $(window).resize(lockMap);
  $(window).resize(checkScroll);

  // // oh god what a grody hack. TODO: find out why this happens and fixitfixitfixit
  // $('#content .main .inner .events, .venue.mode .events').on("click", ".linkto", loadModal);
  // $(".window .linkto").click(loadModal);
  var slideTime = 0;
  $('.filter-text').click(function(event) {

    var thisToggle = $(this).parents('.filter-toggle');
    
    var otherToggled = thisToggle.siblings('.filter-toggle.selected');
    
    otherToggled.find('.filter-dropdown').slideUp(slideTime, function() { otherToggled.removeClass('selected'); });

    if (thisToggle.hasClass('selected')) {
      thisToggle.find('.filter-dropdown').slideUp(slideTime, function() { thisToggle.removeClass('selected'); });
    } else {
      thisToggle.addClass('selected');
      thisToggle.find('.filter-dropdown').slideDown(slideTime);
    }
  });

  $('.filter-toggle').click(function(event) {
    event.stopPropagation();
  });

  $('html').click(function() {
    $('.filter-toggle.selected .filter-text').click();
  });

  advancedSlideTime = 200;
  filterSlideTime = 100;
  
  marginHeight = $('.expandobar').height() + 10;
  baseHeight = $('#header .one').height() + marginHeight;
  filterHeight = baseHeight + $('.filterbar').height();
  advancedHeight = baseHeight + $('.advancedbar').height();

  $('.expandobar-inner').click(function () {
    if($(this).hasClass('expanded')) {
      $('.advancedbar').slideUp(advancedSlideTime, function() {  $('.filterbar').slideDown(filterSlideTime) });
      $('#content, #map-wrapper').animate(
        { "margin-top" : baseHeight },
        advancedSlideTime, 
        function() { 
          $('#content, #map-wrapper').animate(
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
      $('#content, #map-wrapper').animate(
        { "margin-top" : baseHeight },
        filterSlideTime, 
        function() { 
          $('#content, #map-wrapper').animate(
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

  // if($("#map").length > 0)
  //   mapOffset = $("#map").offset().top;

  checkScroll();
});

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
    icon: "/assets/markers/marker_" + (i + 1) + ".png",
    index: i + 1
  });

  google.maps.event.addListener(marker, 'mouseover', function() {
    marker.setIcon("/assets/markers/marker_hover_" + marker.index +  ".png");
    $("#content .main .inner .events li:nth-child(" + marker.index + ")").addClass("hover");
    markers[i].foo = "bar";
  });

  google.maps.event.addListener(marker, 'mouseout', function() {
    marker.setIcon("/assets/markers/marker_" + marker.index + ".png");
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
  loading('show');

  var visibleTagListID = $('.child-tags-menu:visible').attr('tag-id');
  $.get("/events/index?ajax=true", filter, function (data) {
    var locations = [];

    var jData = $(data);

    $('#content .main .inner').html(jData.find("#combo_event_list").html());
    $('#header .filter-toggle.tags .filter-inner').html(jData.find("#combo_tag_list").html());
    $('#header .advancedbar .tags-list').html(jData.find("#combo_advanced_tag_list").html());

    if(visibleTagListID) {
      $('.child-tags-menu[tag-id=' + visibleTagListID + ']').show();
      $('.tag-header[tag-id=' + visibleTagListID + '] .toggler').html("&#x25BC;");
    }

    $('#content .main .inner .events li').each(function(index) {
      locations.push({lat: $(this).find('.latitude').html(), 
                     long: $(this).find('.longitude').html()});
    });

    placeMarkers({points: locations});

    loading('hide');

    updateViewFromFilter(false);
    checkScroll();
  });
}

function loading(command) {
  if (command === 'show') {
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
  } else if (command === 'hide') {
    $('.main .inner .header, .main .inner .events').css('opacity','1');
    $('#loading').hide();
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

function lockMap() {
  // if($("#body").scrollTop() >= mapOffset) {
  //   $('#map').css({ position: 'fixed', top: 0, right: scrollbarWidth + 'px', float: 'none' });
  // } else {
  //   $('#map').css({ position: 'relative', float: 'right', top: 'auto', right:'auto' });
  // }
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

function loadModal(event) {
  //console.log('loadModal');
  var thing = spawn(things[$(this).attr("linkto")],{id: $(this).attr("link-id")});
  //console.log(thing);
  //console.log(thing.type);
  //console.log(thing.id);
  //var thing = {type:$(this).attr("linkto"), id: $(this).attr("link-id")};
  history.pushState({}, thing.type + " mode", "?" + thing.type + "_id=" + thing.id);
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
    $('.mode .description').html("");
    $('.mode').hide();
    return;
  } else {
    $.get(thing.url(), function(data) {
     //$.get('/' + thing.type + 's/show/' + thing.id, function(data) {
      $('.mode').hide().removeClass().addClass('mode ' + thing.type);
      $('.mode .window').html(data);
      $('.mode').show();
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
