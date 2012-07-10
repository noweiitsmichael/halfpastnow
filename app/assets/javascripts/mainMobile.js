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

  $(".events-seed").hide();

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
     console.log("click on venue addess");
     $('.mode').hide();

  });


  $('#content .sidebar .inner .filter.date span').click(function () {
    $(this).siblings('span').removeClass('selected');
    $(this).addClass('selected');

    $(this).parent().parent().find('.custom-select').removeClass('selected');
    $(this).parent().parent().find('.custom-select:nth-child(' + ($(this).index() + 1) +  ')').addClass('selected');
  });

  $('#content .sidebar .inner .filter.price span').click(toggleSelection);
  $('#content .sidebar .inner .filter.day span').click(toggleSelection);
  $('#content .main .inner .header .sort span').click(radioSelection);  

  $('#content .sidebar .inner .filter.price span').click(filterChange);
  $('#content .sidebar .inner .filter.day span').click(filterChange);
  $('#content .sidebar .inner .filter.date .filters span').click(filterChange);
  $('#content .main .inner .header .sort span').click(filterChange);  

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
  $('.mode .close-btn').click(closeMode);

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

  // oh god what a grody hack. TODO: find out why this happens and fixitfixitfixit
  $('#content .main .inner .events, .venue.mode .events').on("click", ".linkto", loadModal);
  $(".window .linkto").click(loadModal);






  mapOffset = $("#map").offset().top;
});

var mapOffset;

var hours = ['midnight','1 am','2 am','3 am','4 am','5 am','6 am','7 am','8 am','9 am','10 am','11 am','noon','1 pm','2 pm','3 pm','4 pm','5 pm','6 pm','7 pm','8 pm','9 pm','10 pm','11 pm','midnight'];

var day_of_week = ['SUN','MON','TUE','WED','THU','FRI','SAT'];

window.addEventListener("popstate", function(e) {
  console.log("in window.addEventListener");
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
  console.log("modal in closeMode");
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
      li.find(".name").attr("href", events[i].id);
      li.find(".index").html(parseInt(i) + 1);
      li.find(".mod").html(start.toString("MMMdd").toUpperCase());
      li.find(".day").html(day_of_week[events[i].occurrences[0].day_of_week]);
      li.find(".time").html(start.toString("hh:mmtt").toLowerCase());
      li.find(".one .name").html(events[i].title);
      li.find(".one .venue").html(events[i].venue.name);
      li.find(".one .venue").attr("href",events[i].venue_id);
      if(events[i].price!=null)
        if(events[i].price!=0)
          li.find(".one .description").html("<span ><strong>Price:  $" + parseFloat(events[i].price).toFixed(2) + "</strong></span> " + events[i].description);
        else li.find(".one .description").html("<span ><strong>Free</strong></span> " +events[i].description);
      else li.find(".one .description").html(events[i].description);
      li.prependTo('#content .main .inner .events-seed');
      locations.push({lat: events[i].venue.latitude, long: events[i].venue.longitude});
    }

    //placeMarkers({points: locations});

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
    console.log("top: " + top);
    var bottom = $('.main .inner .events').height() - Math.max(0,$('.main .inner .events').height() + $('.main .inner .events').offset().top - $(window).height() - $(window).scrollTop());
    console.log("bottom: " + bottom);
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
  console.log("in loadModal");
  var thing = {type:$(this).attr("linkto"), id: $(this).attr("href")};
  history.pushState(thing, thing.type + " mode", "?" + thing.type + "_id=" + thing.id);
  if($(this).is("#content .main .events li .venue")) {
     event.stopPropagation();
  }
  //modal(thing);
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
  } else {
    return null;
  }
}

function demodal() {
  console.log("in demodal");
  modal();
}

function to_ordinal(num) {
   
    var ordinal = ["th","st","nd","rd","th","th","th","th","th","th"] ;
    return num.toString() + ordinal[num%10];
}



function modal(thing) {
  console.log("in modal :");
  var j=0;
  var k=0;
  var h=0;
  ///////////////////////
     console.log("in modal and thing not null - called once ");
 
          $(document).bind("pagebeforechange", function(e, data) {
  // We only want to handle changePage() calls where the caller is asking to load a page by URL.
  console.log("url in modal : "+data.toPage);
   
     console.log("j : "+j);
      
   
  if (typeof data.toPage === "string") {
      
      var u = $.mobile.path.parseUrl(data.toPage);
      var qrcode = /^#event/;
      var vcode = /^#venue/;
      if (data.toPage.localeCompare("/")===0){
         // injet data for homepage here
        
      }
      else if (u.hash.search(qrcode) === 0){
            console.log("else : "+data.toPage);
      
         // We only want to handle #qrcode url.
           
          console.log("hash :"+u.hash);
          var title ;
          var qrUrl = decodeURIComponent(u.hash.replace(/.*event_id=/, ""));
          $.getJSON('/events/show/' + qrUrl + '.json', function(event) {
            start = new Date(event.occurrences[0].start);
            console.log("Json called " + event.title);
            $('#event_infos h1').html(event.title);
            $('#event_infos .event_description span').html(event.description);
            $('#event_infos .map').attr("src","http://maps.googleapis.com/maps/api/staticmap?size=430x170&zoom=15&maptype=roadmap&markers=color:red%7C" + event.venue.latitude  +  "," + event.venue.longitude + "&style=feature:all|hue:0x000001|saturation:-50&sensor=false");
            $('#event_infos .map-link').attr("href","http://maps.google.com/maps?q=" + event.venue.latitude  + "," + event.venue.longitude);
            $('#event_infos a.venue-link').html(event.venue.name);
            //<a href="<%= event ? "#event?event_id=" + event.id.to_s : "" %>" data-transition="slidedown"> 
            $('#event_infos a.venue-link').attr("href", "#venue?venue_id=" + event.venue.id);
            $('#event_infos .price').html(event.price ? ((event.price==0)?"<strong>Free</strong>" : "<strong>Price: </strong> <span>$" + parseFloat(event.price).toFixed(2) + "</span>" ): "");
            $('#event_infos .add1').html(event.venue.address);
            $('#event_infos .add2').html(event.venue.city + ", " + event.venue.state + " " + event.venue.zip);
          });
          console.log("eventID :"+qrUrl);
          var pageSelector = u.hash.replace(/\?.*$/, "");


          var $page = $(pageSelector);
          console.log("pageSelector :"+pageSelector+" page :"+$page);
          var options = data.options;
          // Get the header for the page.
          var $header = $page.children(":jqmData(role=header)");

          // Find the h1 element in the header and inject the hostname from the url.
          $header.find("h1").html("Event : "+qrUrl);

          // Get the content area element for the page.
          var $content = $page.children(":jqmData(role=content)");

         
          options.dataUrl = u.href;


          // Now call changePage() and tell it to switch to the page we just modified.
          if (j==0){
            e.preventDefault();
            $.mobile.changePage($page,  options);
            //$.mobile.changePage(u.href);
            console.log("After loadpage");
            j=j+1;
           // break;
          }
          
      }
      else if(u.hash.search(vcode) === 0){
        console.log("Venue mode");
        var vUrl = decodeURIComponent(u.hash.replace(/.*venue_id=/, ""));
        $.getJSON('/venues/show/' + vUrl + '.json', function(venueInfo) {
          venue = $.parseJSON(venueInfo.venue);
          recurrences = $.parseJSON(venueInfo.recurrences);
          occurrences = $.parseJSON(venueInfo.occurrences);
          var li;

          $('#venue .vevents').empty();

          $('#venue h1').html(venue.name);
          $('#venue .address.onee').html(venue.address);
          $('#venue .address.two').html(venue.city + ", " + venue.state + " " + venue.zip);
          $('#venue .map').attr("src","http://maps.googleapis.com/maps/api/staticmap?size=430x170&zoom=15&maptype=roadmap&markers=color:red%7C" + venue.latitude  +  "," + venue.longitude + "&style=feature:all|hue:0x000001|saturation:-50&sensor=false");
          $('#venue .map-link').attr("href","http://maps.google.com/maps?q=" + venue.latitude  + "," + venue.longitude);
          $('#venue .description').html(venue.description);

          if (venue.phonenumber=="") { 
            $('#venue .phone span').html("Not Available");
          } else {
            $('#venue .phone span').html(venue.phonenumber);
          }
          //$('.mode.venue .url a').html(venue.name);
          //$('.mode.venue .url a').attr("href", venue.url);
          if (venue.url=="") { 
            $('#venue .details a.url').html("Not Available");
          } 
            else {
              $('#venue .details a.url').html(venue.name);
              $('#venue .details a.url').attr("href", venue.url);
            }

          //////////////////////////////////////////////////////////////////////////////////////

          var week = ["sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"] ;
      
      
        
            $('#venue .vevents-seed1 li:not(:first-child)').each(function() {
              $(this).remove();
            });
          
            $('#venue .vevents-seed2 li:not(:first-child)').each(function() {
              $(this).remove();
            });
      
            // For recurrences
            if(recurrences.length > 0) {
              for (var i in recurrences) {
                var event = recurrences[i].event;
                console.log("event name :"+event.title);
                var startTime = Date.parse(recurrences[i].start.substr(0,19));
                
                var mod = "EVERY " + ((recurrences[i].every_other == 0) ? "" : ((recurrences[i].every_other == 1) ? "OTHER" : to_ordinal(recurrences[i].every_other)));
                console.log("Mod : " + mod);

                var day = (recurrences[i].day_of_week != null && recurrences[i].week_of_month != null) ? 
                  "<sup>" + to_ordinal(recurrences[i].week_of_month) + "</sup> " + day_of_week[recurrences[i].day_of_week] :
                  ((recurrences[i].day_of_month != null) ? 
                    "<sup class='day-of-month'>" + to_ordinal(recurrences[i].day_of_month) + "</sup>" :
                    ((recurrences[i].day_of_week != null) ? 
                      day_of_week[recurrences[i].day_of_week] : 
                      "DAY"));
                var time = startTime.toString("hh:mmtt").toLowerCase();
                
                li=$($('#venue .vevents-seed1 li:last-child').clone().wrap('<ul>').parent().html());
                li.addClass("recurrence");
                li.find(".mod").html(mod);
                li.find(".day").html(day);
                li.find(".time").html(time);
                li.find(" a.linkto-name").attr("href",  "#event?event_id=" +event.id);
                li.find(" a.linkto-name").html(event.title);
                li.find(".one .description").html(event.description);
                li.appendTo('#venue .vevents-seed1');
              }
            
              $('#venue .vevents-seed1 li:not(:first-child)').each(function() {
                $(this).appendTo('#venue .vevents');
              });
            }

            
            if(occurrences.length > 0) {
              for (var i in occurrences){

                var event = occurrences[i].event;
                console.log("event name :"+event.title);
                var startTime = Date.parse(occurrences[i].start.substr(0,19));
                var dateString = startTime.toString("MMMdd").toUpperCase();
                
                li=$($('#venue .vevents-seed2 li:last-child').clone().wrap('<ul>').parent().html());
                li.find(".mod").html(dateString);
                li.find(".day").html(day_of_week[occurrences[i].day_of_week]);
                li.find(".time").html(startTime.toString("hh:mmtt").toLowerCase());
                li.find(" a.linkto-name").attr("href",  "#event?event_id=" +event.id);
                li.find(" a.linkto-name").html(event.title);
                li.find(".one .description").html(event.description);
                li.appendTo('#venue .vevents-seed2');
              }
              
              $('#venue .vevents-seed2 li:not(:first-child)').each(function() {
                $(this).appendTo('#venue .vevents');
              });
            }

            $('#venue').show();    
            $('#venue .vevents-seed2').hide();
            $('#venue .vevents-seed1').hide(); 
            


          // Now call changePage() and tell it to switch to the page we just modified.
            var pageSelector = u.hash.replace(/\?.*$/, "");


            var $page = $(pageSelector);
            var options = data.options;
            options.dataUrl = u.href;
            if (k==0){
             e.preventDefault();
            $.mobile.changePage($page,  options);
            //$.mobile.changePage(u.href);
            console.log("After loadpage");
            k=k+1;
           // break;
          }
          
           


          });


      }

  
  }
});
///////////////////////////////////////////////


  if(!thing) {

    
    $('.mode').hide();
    return;
  }

// Listen for any attempts to call changePage().

  
  if(thing.type === "event") {
    console.log("thing not null in event");
 
    $.getJSON('/events/show/' + thing.id + '.json', function(event) {

      start = new Date(event.occurrences[0].start);
      $('.mode.event .time.one').html(start.toString("dddd, MMMM d"));
      $('.mode.event .time.two').html(start.toString("h:mmtt"));
      $('.mode.event h1').html(event.title);
      $('.mode.event .venue a').html(event.venue.name);
      $('.mode.event .venue a').attr("href", event.venue.id);
      $('.mode.event .address.one').html(event.venue.address);
      $('.mode.event .address.two').html(event.venue.city + ", " + event.venue.state + " " + event.venue.zip);
      $('.mode.event .price').html(event.price ? "<strong>Price: </strong> <span>$" + parseFloat(event.price).toFixed(2) + "</span>" : "");
      $('.mode.event .map').attr("src","http://maps.googleapis.com/maps/api/staticmap?size=430x170&zoom=15&maptype=roadmap&markers=color:red%7C" + event.venue.latitude  +  "," + event.venue.longitude + "&style=feature:all|hue:0x000001|saturation:-50&sensor=false");
      $('.mode.event .map-link').attr("href","http://maps.google.com/maps?q=" + event.venue.latitude  + "," + event.venue.longitude);
      $('.mode.event .description').html(event.description);
      $('.mode').hide();
      $('.mode.event').show();
    });
  } else {
    console.log("thing not null in venue");
    $.getJSON('/venues/show/' + thing.id + '.json', function(venueInfo) {
      venue = $.parseJSON(venueInfo.venue);
      recurrences = $.parseJSON(venueInfo.recurrences);
      occurrences = $.parseJSON(venueInfo.occurrences);
      var week = ["sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday"] ;
      
      var li;
      $('.venue.mode .overlay .window .inner .menu .selected .events').empty();
      
      $('.venue.mode .overlay .window .inner .menu .selected .events-seed1 li:not(:first-child)').each(function() {
        $(this).remove();
      });
    
      $('.venue.mode .overlay .window .inner .menu .selected .events-seed2 li:not(:first-child)').each(function() {
        $(this).remove();
      });
      console.log(recurrences);
      // For recurrences
      if(recurrences.length > 0) {
        for (var i in recurrences) {
          var event = recurrences[i].event;
          var startTime = Date.parse(recurrences[i].start.substr(0,19));
          
          var mod = "EVERY " + ((recurrences[i].every_other == 0) ? "" : ((recurrences[i].every_other == 1) ? "OTHER" : to_ordinal(recurrences[i].every_other)));
          var day = (recurrences[i].day_of_week != null && recurrences[i].week_of_month != null) ? 
            "<sup>" + to_ordinal(recurrences[i].week_of_month) + "</sup> " + day_of_week[recurrences[i].day_of_week] :
            ((recurrences[i].day_of_month != null) ? 
              "<sup class='day-of-month'>" + to_ordinal(recurrences[i].day_of_month) + "</sup>" :
              ((recurrences[i].day_of_week != null) ? 
                day_of_week[recurrences[i].day_of_week] : 
                "DAY"));
          var time = startTime.toString("hh:mmtt").toLowerCase();
          
          li=$($('.venue.mode .overlay .window .inner .menu .selected .events-seed1 li:last-child').clone().wrap('<ul>').parent().html());
          li.addClass("recurrence");
          li.find(".mod").html(mod);
          li.find(".day").html(day);
          li.find(".time").html(time);
          li.find(".name").attr("href", event.id);
          li.find(".name").html(event.title);
          li.find(".one .description").html(event.description);
          li.appendTo('.venue.mode .overlay .window .inner .menu .selected .events-seed1');
        }
      
        $('.venue.mode .overlay .window .inner .menu .selected .events-seed1 li:not(:first-child)').each(function() {
          $(this).appendTo('.venue.mode .overlay .window .inner .menu .selected .events');
        });
      }

      // For occurrences
      if(occurrences.length > 0) {
        for (var i in occurrences){
          var event = occurrences[i].event;
          var startTime = Date.parse(occurrences[i].start.substr(0,19));
          var dateString = startTime.toString("MMMdd").toUpperCase();
          
          li=$($('.venue.mode .overlay .window .inner .menu .selected .events-seed2 li:last-child').clone().wrap('<ul>').parent().html());
          li.find(".mod").html(dateString);
          li.find(".day").html(day_of_week[occurrences[i].day_of_week]);
          li.find(".time").html(startTime.toString("hh:mmtt").toLowerCase());
          li.find(".name").attr("href", event.id);
          li.find(".name").html(event.title);
          li.find(".one .description").html(event.description);
          li.appendTo('.venue.mode .overlay .window .inner .menu .selected .events-seed2');
        }
        
        $('.venue.mode .overlay .window .inner .menu .selected .events-seed2 li:not(:first-child)').each(function() {
          $(this).appendTo('.venue.mode .overlay .window .inner .menu .selected .events');
        });
      }

      $('.mode.venue h1').html(venue.name);
      $('.mode.venue .address.one').html(venue.address);
      $('.mode.venue .address.two').html(venue.city + ", " + venue.state + " " + venue.zip);
      $('.mode.venue .map').attr("src","http://maps.googleapis.com/maps/api/staticmap?size=430x170&zoom=15&maptype=roadmap&markers=color:red%7C" + venue.latitude  +  "," + venue.longitude + "&style=feature:all|hue:0x000001|saturation:-50&sensor=false");
      $('.mode.venue .map-link').attr("href","http://maps.google.com/maps?q=" + venue.latitude  + "," + venue.longitude);
      $('.mode.venue .description').html(venue.description);
      if (venue.phonenumber=="") { 
        $('.mode.venue .phone span').html("Not Available");
      } else {
        $('.mode.venue .phone span').html(venue.phonenumber);
      }
      //$('.mode.venue .url a').html(venue.name);
      //$('.mode.venue .url a').attr("href", venue.url);
      if (venue.url=="") { 
        $('.mode.venue .url a').html("Not Available");
      } 
        else {
          $('.mode.venue .url a').html(venue.name);
          $('.mode.venue .url a').attr("href", venue.url);
        }
      $('.mode').hide();
      $('.mode.venue').show();    
      $('.venue.mode .overlay .window .inner .menu .selected .events-seed2').hide();
      $('.venue.mode .overlay .window .inner .menu .selected .events-seed1').hide();
    });
  }
}
