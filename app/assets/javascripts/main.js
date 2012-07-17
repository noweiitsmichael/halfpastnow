$(function() {

  $(".today.time-range").slider({
    range: true,
    min: 0,
    max: 24,
    values: [ 0, 24 ],
    slide: function( event, ui ) {
      if(ui.values[0] == 0 && ui.values[1] == 24)
        $(".today.time-display").html("all day");
      else
        $(".today.time-display").html("from " + hours[ui.values[0]] + " to " + hours[ui.values[1]]);
    },
    stop: filterChange
  });

  $(".tomorrow.time-range").slider({
    range: true,
    min: 0,
    max: 24,
    values: [ 0, 24 ],
    slide: function( event, ui ) {
      if(ui.values[0] == 0 && ui.values[1] == 24)
        $(".tomorrow.time-display").html("all day");
      else
        $(".tomorrow.time-display").html("from " + hours[ui.values[0]] + " to " + hours[ui.values[1]]);
    },
    stop: filterChange
  });

  $('.more-tags').click(function() {
    if($('.filter.tags').hasClass('expanded')) {
      $('.more-tags').html("&#x25BE; more");
    } else {
      $('.more-tags').html("&#x25B4; less");
    }
    $('.filter.tags').toggleClass('expanded');
  });

  $('.mode.venue .address.one').click(function(){
     $('.mode').hide();

  });


  $('#content .sidebar .inner .filter.date span').click(function () {
    $(this).siblings('span').removeClass('selected');
    $(this).addClass('selected');

    $(this).parent().parent().find('.custom-select').removeClass('selected');
    $(this).parent().parent().find('.custom-select:nth-child(' + ($(this).index() + 1) +  ')').addClass('selected');
  });
  $('#content .sidebar .inner .filter.day span').click(function() {
    $('#content .sidebar .inner .filter.date span.custom').click();
  });
  $('#content .sidebar .inner .filter.price span').click(toggleSelection);
  $('#content .sidebar .inner .filter.day span').click(toggleSelection);
  $('#content .main .inner .header .sort span').click(radioSelection);  

  $('#content .sidebar .inner .filter.price span').click(filterChange);
  $('#content .sidebar .inner .filter.day span').click(filterChange);
  $('#content .sidebar .inner .filter.date .filters span').click(filterChange);
  $('#content .main .inner .header .sort span').click(filterChange);  
  $('#content .sidebar .inner .filter.date .custom-select input.date').blur(filterChange);

  $('#content .sidebar .inner .filter.date .date ').datetimepicker({
    ampm: true,
    showMinute: false,
    hour: (new Date()).getHours(),
    minute: 0,
    dateFormat: 'D m/d',
    timeFormat: 'h:mmtt',
    separator: ' @ '
  });

  $('.mode .overlay').click(closeMode);

  $('.mode .overlay .window').click(function(event) {
    event.stopPropagation();
  });
  
  $(".mode .window .menu li").click(function() {
    var index = $(this).index();
    $(this).siblings().removeClass("selected");
    $(this).addClass("selected");
    $(this).parent().parent().children("div").removeClass("selected");
    $(this).parent().parent().children("div").eq(index).addClass("selected");
  });

  $('#content .main .inner .events').on("mouseenter", "li", function() {
    google.maps.event.trigger(markers[$(this).index()], 'mouseover');
  });
  
  $('#content .main .inner .events').on("mouseleave", "li", function() {
    google.maps.event.trigger(markers[$(this).index()], 'mouseout');
  });

  $('#body').scroll(showPageMarkers);
  $('#body').scroll(lockMap);
  
  $(window).resize(showPageMarkers);
  $(window).resize(lockMap);

  // // oh god what a grody hack. TODO: find out why this happens and fixitfixitfixit
  // $('#content .main .inner .events, .venue.mode .events').on("click", ".linkto", loadModal);
  // $(".window .linkto").click(loadModal);
  $("#content .main .inner .events").on("click", ".linkto", loadModal);
  // $("#overlays").on("click", ".linkto", loadModal);


  if($("#map").length > 0)
    mapOffset = $("#map").offset().top;
});

var mapOffset;

var hours = ['midnight','1 am','2 am','3 am','4 am','5 am','6 am','7 am','8 am','9 am','10 am','11 am','noon','1 pm','2 pm','3 pm','4 pm','5 pm','6 pm','7 pm','8 pm','9 pm','10 pm','11 pm','midnight'];

var day_of_week = ['SUN','MON','TUE','WED','THU','FRI','SAT'];

window.addEventListener("popstate", function(e) {
  var query = e.target.location.search;
  if(query !== "") {
    modal(parsequery(query));
  } else {

    demodal();
  }
});

// var today = Date.today();

var filter = {
  start: Date.today(),
  end: Date.today().add({days: 1}),
  day: [0,1,2,3,4,5,6],
  price: [0,1,2,3,4],
  tags: [],
  latMin: null,
  latMax: null,
  longMin: null,
  longMax: null,
  offset: 0,
  search: null,
  sort: 0
};

var boundsChangedFlag = false;
function boundsChanged() {
  filter.latMin = map.getBounds().getSouthWest().lat();
  filter.latMax = map.getBounds().getNorthEast().lat();
  filter.longMin = map.getBounds().getSouthWest().lng();
  filter.longMax = map.getBounds().getNorthEast().lng();
  if(boundsChangedFlag) {
    filterChange();
  }
  boundsChangedFlag = true;
}

function closeMode(){
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
    $("#content .main .inner .events LI:nth-child(" + marker.index + ")").addClass("hover");
    markers[i].foo = "bar";
  });

  google.maps.event.addListener(marker, 'mouseout', function() {
    marker.setIcon("/assets/markers/marker_" + marker.index + ".png");
    $("#content .main .inner .events LI:nth-child(" + marker.index + ")").removeClass("hover");
  });

  google.maps.event.addListener(marker, 'click', function() {
    $("#content .main .inner .events LI:nth-child(" + marker.index + ") .name").click();
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

// on change of filter
function filterChange() {
  updateFilter();
  pullEvents();
  //put events in page
}

function updateFilter() {
  filter.tags = [];
  var selectedTags = $('#tag-input').tokenInput("get");
  for(var i in selectedTags) {
    filter.tags.push(selectedTags[i].id);
  }

  switch ($(".filter.date .filters .selected").index()) {
    case 0:
      filter.start = Date.today().add({hours:$(".today.time-range").slider("values",0)});
      filter.end = Date.today().add({hours:$(".today.time-range").slider("values",1)});
      break;
    case 1:
      filter.start = Date.today().add({hours:$(".tomorrow.time-range").slider("values",0), days:1});
      filter.end = Date.today().add({hours:$(".tomorrow.time-range").slider("values",1), days:1});
      break;
    case 2:
      filter.start = $('#content .sidebar .inner .filter.date .start.date').datepicker("getDate");
      filter.end = $('#content .sidebar .inner .filter.date .end.date').datepicker("getDate");
      break;
  }
  
  filter.day = [];
  $('#content .sidebar .inner .filter.day span.selected').each(function () {
    filter.day.push($(this).index());
  });

  filter.price = [];
  $('#content .sidebar .inner .filter.price span.selected').each(function () {
    filter.price.push($(this).index());
  });

  filter.sort = $("#content .main .inner .header .sort span.selected").index();
}

// this gets called on infinite scroll and on filter changes
function pullEvents() {
  var query = "";

  if(filter.start)
    query += "&start=" + (filter.start.getTime() / 1000);
  if(filter.end)
    query += "&end=" + (filter.end.getTime() / 1000);
  if(filter.search)
    query += "&search=" + filter.search;
  if(filter.latMin)
    query += "&lat_min=" + filter.latMin;
  if(filter.latMax)
    query += "&lat_max=" + filter.latMax;
  if(filter.longMin)
    query += "&long_min=" + filter.longMin;
  if(filter.longMax)
    query += "&long_max=" + filter.longMax;
  if(filter.day.length > 0 && filter.day.length < 7)
    query += "&day=" + filter.day.reduce(function(a,b) { return a + "," + b; },"").substring(1);
  if(filter.price.length > 0 && filter.price.length < 5)
    query += "&price=" + filter.price.reduce(function(a,b) { return a + "," + b; },"").substring(1);
  if(filter.tags.length > 0)
    query += "&tags=" + filter.tags.reduce(function(a,b) { return a + "," + b; },"").substring(1);
  if(filter.offset)
    query += "&offset=" + filter.offset;
  if(filter.sort)
    query += "&sort=" + filter.sort;
  loading('show');
  $.getJSON("/events/index?format=json" + query, function (events) {
    var locations = [];
    for(var i in events) {
      var start = Date.parse(events[i].occurrences[0].start.substr(0,19));
      var li = $($('#content .main .inner .events-seed li:last-child').clone().wrap('<ul>').parent().html());
      li.find(".name").attr("href", events[i].occurrences[0].id);
      li.find(".index").html(parseInt(i) + 1);
      li.find(".mod").html(start.toString("MMMdd").toUpperCase());
      li.find(".day").html(day_of_week[events[i].occurrences[0].day_of_week]);
      li.find(".time").html(start.toString("hh:mmtt").toLowerCase());
      li.find(".one .name").html(events[i].title);
      li.find(".one .venue").html(events[i].venue.name);
      li.find(".one .venue").attr("href",events[i].venue_id);
      li.find(".one .description").html(strip(events[i].description));

      if(events[i].price == 0)
        li.find(".one .description").prepend("<span><strong>FREE</strong></span> ");
      else if(events[i].price > 0)
        li.find(".one .description").prepend("<span><strong>$" + parseFloat(events[i].price).toFixed(2) + "</strong></span> ");
        
      li.prependTo('#content .main .inner .events-seed');
      locations.push({lat: events[i].venue.latitude, long: events[i].venue.longitude});
    }

    placeMarkers({points: locations});

    $('#content .main .inner .events').empty();
    $('#content .main .inner .header .count').html(events.length + " event" + ((events.length == 1) ? "" : "s"));
    $('#content .main .inner .events-seed li:not(:last-child)').each(function() {
      $(this).prependTo('#content .main .inner .events');
    });
    loading('hide');
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
  if($("#body").scrollTop() >= mapOffset) {
    $('#map').css({ position: 'fixed', top: 0, left: 0, float: 'none' });
  } else {
    $('#map').css({ position: 'relative', float: 'left' });
  }
}

function loadModal(event) {

  var thing = {type:$(this).attr("linkto"), id: $(this).attr("href")};
  history.pushState(thing, thing.type + " mode", "?" + thing.type + "_id=" + thing.id);
  if($(this).is("#content .main .events li .venue")) {
     event.stopPropagation();
  }
  modal(thing);
  return false;
}

//only works for one parameter. lol
function parsequery(query) {
  query = query.substring(1, query.length);
  var queryArr = query.split('=');
  if(queryArr[0] == "venue_id") {
    return { type: "venue", id: queryArr[1] };
  } else if(queryArr[0] == "event_id") {
    return { type: "event", id: queryArr[1] };
  } else if(queryArr[0] == "act_id") {
    return { type: "act", id: queryArr[1] };
  } else {
    return null;
  }
}

function demodal() {
  modal();
}

function to_ordinal(num) {
   
    var ordinal = ["th","st","nd","rd","th","th","th","th","th","th"] ;
    return num.toString() + ordinal[num%10];
}

function strip(html)
{
  var tmp = document.createElement("DIV");
  tmp.innerHTML = html;
  return tmp.textContent || tmp.innerText;
}

function modal(thing) {

  if(!thing) {
    $('.mode .description').html("");
    $('.mode').hide();
    return;
  } else {
    $.get('/' + thing.type + 's/show/' + thing.id, function(data) {
      $('.mode').hide().removeClass().addClass('mode ' + thing.type);
      $('.mode .window').html(data);
      $('.mode .linkto').click(loadModal);
      $('.mode .close-btn').click(closeMode);
      $('.mode').show(); 
      $('.mode .add_bookmark').click(function() {
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
      $('.mode .remove_bookmark').click(function() {
        $.ajax('/bookmarks/' + $(this).attr('bookmark-id'),{
          type: "DELETE",
          dataType: "json",
          success: function() {
            $('.mode .remove_bookmark').hide();
            $('.mode .add_bookmark').show();
          }
        });
      });
    });
  }
}


