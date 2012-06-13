// Listen for any attempts to call changePage().
var filter = {
  start: Date.today(),
  end: Date.today().add({days: 365}),
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
var pricesOut=[];
var radioStatus="off";
var searchReg = "true";
// 30.268093,-97.742808
var latitude =  30.268093 ,longitude = -97.742808;
var distLocation = 0;
var dist;



$(function() {



  $("#home .events-seed").hide();
  $('#prices').live( "change", function(event, ui) {
  localStorage['activity'] = $(this).val();
  pricesOut = localStorage['activity'];
  console.log("Price : "+localStorage['activity']);
  filter.price=[];
  if(localStorage['activity']!="null")
  for(var i in localStorage['activity']) {
   console.log("In Array out "+localStorage['activity'][i]);
   if((i%2)==0)
    {
      console.log("In Array "+localStorage['activity'][i]);
      filter.price.push(localStorage['activity'][i]);
    }

   
  }
  // filterChange();
  console.log("Tags : "+filter.tags.reduce(function(a,b) { return a + "," + b; },"").substring(1));
  console.log("Price (indeed) : "+filter.price);
  console.log("Day (indeed) : "+filter.day);
  console.log("searchReg : "+searchReg);
  console.log("searchTerm : "+filter.searchTerm);


});

$('#day').live( "change", function(event, ui) {
  localStorage['activity'] = $(this).val();
  pricesOut = localStorage['activity'];
  console.log("day : "+localStorage['activity']);
  filter.day=[];
  filter.start = Date.today();
  filter.end = Date.today().add({days:365});
  if(localStorage['activity']!="null")
  for(var i in localStorage['activity']) {
   console.log("Day In Array out "+localStorage['activity'][i]);
   if((i%2)==0)
    {
      console.log("Day In Array "+localStorage['activity'][i]);
      filter.day.push(localStorage['activity'][i]);
    }

    
  }
 // filterChange();
 console.log("Tags : "+filter.tags.reduce(function(a,b) { return a + "," + b; },"").substring(1));
  console.log("Price (indeed) : "+filter.price);
  console.log("Day (indeed) : "+filter.day);
  console.log("searchReg : "+searchReg);
  console.log("searchTerm : "+filter.searchTerm);
});

  $('#distance').live( "change", function(event, ui) {
  localStorage['activity'] = $(this).val();
  distLocation = $(this).val();
  console.log("Distance : "+localStorage['activity']);




});

$("#filter input[type='radio']").bind( "change", function(event, ui) {
  console.log("radio clicked : " + $(this).val());
  radioStatus=$(this).val();
  if (radioStatus=="0"){
    filter.start = Date.today();
    filter.end = Date.today().add({days:1});
  }
  else if(radioStatus=="1"){
    filter.start = Date.today().add({days:1});
    filter.end = Date.today().add({days:2});
  }
  else {
    filter.start = Date.today();
    filter.end = Date.today().add({days:365});
  }

  //filterChange();
  console.log("Tags : "+filter.tags.reduce(function(a,b) { return a + "," + b; },"").substring(1));
  console.log("Price (indeed) : "+filter.price);
  console.log("Day (indeed) : "+filter.day);
  console.log("searchReg : "+searchReg);
  console.log("searchTerm : "+filter.searchTerm);

 


});

})



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

var boundsChangedFlag = false;
function boundsChanged() {
  filter.latMin = map.getBounds().getSouthWest().lat();
  filter.latMax = map.getBounds().getNorthEast().lat();
  filter.longMin = map.getBounds().getSouthWest().lng();
  filter.longMax = map.getBounds().getNorthEast().lng();
  console.log("filter.latMin "+filter.latMin);
  console.log("filter.latMax "+filter.latMax);
  console.log("filter.longMin "+filter.longMin);
  console.log("filter.longMax "+filter.longMax);
  if(boundsChangedFlag) {
    filterChange();

  }
  boundsChangedFlag = true;

}


function filterChange() {
  console.log("Filter change aover all");
  console.log("Tags : "+filter.tags.reduce(function(a,b) { return a + "," + b; },"").substring(1));
  console.log("Price (indeed) : "+filter.price);
  console.log("Day (indeed) : "+filter.day);
  console.log("searchReg : "+searchReg);
  console.log("searchTerm : "+filter.search);
  console.log("Distance : "+distLocation);
  updateFilter();
  pullEvents();

  
 
  //put events in page
}


function updateFilter() {
  console.log("Update filter");
  filter.tags = [];
  var selectedTags = $('#tag-input').tokenInput("get");
  for(var i in selectedTags) {
   
    filter.tags.push(selectedTags[i].id);
  }
  
 
  
  console.log("Tags : "+filter.tags.reduce(function(a,b) { return a + "," + b; },"").substring(1));
  console.log("Price (indeed) : "+filter.price);
  console.log("Day (indeed) : "+filter.day);
}

function pullSearch() {
  console.log("pullSearch called - json");
  // $.getJSON('/events/show/51.json', function(event) {

  //   console.log(event);
  // });
  $.getJSON('/events/indexMobile?search=movie&format=mobile', function(event) {

    console.log(event);
  });

  
}
function pullEvents() {
  var query = "";
  var test ="test";
  
  if(filter.start)
    query += "&start=" + (filter.start.getTime() / 1000);
  if(filter.end)
    query += "&end=" + (filter.end.getTime() / 1000);
  if(filter.search)
    query += "&search="+filter.search;
  if(filter.search)
    query += "&search1="+filter.search;
  if(filter.latMin)
    query += "&lat_min=" + filter.latMin;
  if(filter.latMax)
    query += "&lat_max=" + filter.latMax;
  if(filter.longMin)
    query += "&long_min=" + filter.longMin;
  if(filter.longMax)
    query += "&long_max=" + filter.longMax;
  if(filter.day.length > 0 && filter.day.length < 7)
    query += "&day=" + filter.day.reduce(function(a,b) { return a + "," + b; },"").substring(1);;
  if(filter.price.length > 0 && filter.price.length < 5)
    query += "&price=" + filter.price.reduce(function(a,b) { return a + "," + b; },"").substring(1);
  if(filter.tags.length > 0)
    query += "&tags=" + filter.tags.reduce(function(a,b) { return a + "," + b; },"").substring(1);
  if(filter.offset)
    query += "&offset=" + filter.offset;
  if(filter.sort)
    query += "&sort=" + filter.sort;
  query += "&searchReg=" + searchReg;

  // loading('show');
  console.log("Query here: "+query);

  $.getJSON("/events/indexMobile?format=mobile" + query, function (events) {
  //$.getJSON("/events/index?format=json" + query, function (events) {
  
    for(var i in events) {
      console.log("Event title here : "+events[i].title);
      var start = Date.parse(events[i].occurrences[0].start.substr(0,19));
     
      var li = $($('#home .events-seed li:last-child').clone().wrap('<ul>').parent().html());

      li.find("a").attr("href", "#event?event_id=" + events[i].id );
      
      li.find(".name").attr("href", events[i].id);
      li.find(".index").html(parseInt(i) + 1);
      li.find(".mod").html(start.toString("MMMdd").toUpperCase());
      li.find(".day").html(day_of_week[events[i].occurrences[0].day_of_week]);
      li.find(".time").html(start.toString("hh:mmtt").toLowerCase());
      li.find(".one .nameEvent").html(events[i].title.substring(0,25));
      li.find(".longitude").html(events[i].venue.longitude);
      li.find(".latitude").html(events[i].venue.latitude);
      li.find(".eventID").html(events[i].id);
      li.find(".one .where").html(events[i].venue.name);
     
      if(events[i].price!=null)
        if(events[i].price!=0)
          li.find(".one .description").html("<span ><strong>Price:  $" + parseFloat(events[i].price).toFixed(2) + "</strong></span> " + events[i].description.substring(0,25));
        else li.find(".one .description").html("<span><strong>Free</strong></span> " +events[i].description.substring(0,25));
      else li.find(".one .description").html(events[i].description.substring(0,25));
      li.prependTo('#home .events-seed');
     
    
    }
    
   
    

    $('#home .events').empty();
    $('#home .count').html(events.length + " event" + ((events.length == 1) ? "" : "s"));
    $('#home .events-seed li:not(:last-child)').each(function() {
      $(this).prependTo('#home .events');
    });
    // loading('hide');
    var locations = [];
    event_ids=[];
    event_names=[];
    event_descriptions=[];
    venue_names=[];

    $("#home .events li").each(function(index) {
          console.log("should be called after FULLEVENTS ");
          var latitude = parseFloat($(this).find(".latitude").html());
          var longitude = parseFloat($(this).find(".longitude").html());
          console.log("Lat : "+latitude+" Long : "+longitude);
          locations.push({lat: latitude, long: longitude});
          var event_id_j=parseFloat($(this).find(".eventID").html());
          event_ids.push({id:event_id_j});
          
          var event_name;
          event_name=$(this).find(".one .nameEvent").html();
          console.log("Event name: ? "+event_name);
          event_names.push({name:event_name});

          var event_description;
          event_description=$(this).find(".one .description").html();
          event_descriptions.push({description:event_description});

          var venue_name;
          venue_name=$(this).find(".one .where").html();
          venue_names.push({name:venue_name});
        });
    console.log("locations : "+locations.length);
    
    placeMarkers({points: locations});
        //google.maps.event.addListener(map, 'idle', boundsChanged);


  });
}

$(document).bind("pagebeforechange", function(e, data) {
  // We only want to handle changePage() calls where the caller is asking to load a page by URL.
  

 

  if (typeof data.toPage === "string") {
    // We only want to handle #qrcode url.
    var u = $.mobile.path.parseUrl(data.toPage);


   
    var qrcode = /^#event/;
    var vcode = /^#venue/;
    var mcode = /^#mapShow/;
    console.log("toPage new : "+ $.mobile.path.parseUrl(data.toPage).href);
    // filter.start = Date.today();
    // filter.end = Date.today().add({days:365});
    // google.maps.event.trigger(map, "resize");
    if (radioStatus!="off"){
      
      // filter.start = Date.today();
      // filter.end = Date.today().add({days:365});
    }
    if (u.hash.search(qrcode) !== -1) {
      // Display QR code for the selected URL.
      showQRCode(u, data.options);
      e.preventDefault();
      console.log("List Events");
    }
    else if (u.hash.search(vcode) !== -1) {
      // Display QR code for the selected URL.
      showVenue(u, data.options);
      e.preventDefault();
    }
    else if (u.hash.search(mcode) !== -1) {
      // Map
      console.log("to map page "+latitude+","+longitude);
      //boundsChanged();

      mapVariables();
      
    //  map.panTo(new google.maps.LatLng(latitude, longitude));
     
     // e.preventDefault();
     
    }

    // window.location.reload();
  }
});
var hours = ['midnight','1 am','2 am','3 am','4 am','5 am','6 am','7 am','8 am','9 am','10 am','11 am','noon','1 pm','2 pm','3 pm','4 pm','5 pm','6 pm','7 pm','8 pm','9 pm','10 pm','11 pm','midnight'];

var day_of_week = ['SUN','MON','TUE','WED','THU','FRI','SAT'];
function to_ordinal(num) {
   
    var ordinal = ["th","st","nd","rd","th","th","th","th","th","th"] ;
    return num.toString() + ordinal[num%10];
}
function placeMarkers(params) {
  if (typeof params.clear === 'undefined' || params.clear === true)
    clearMarkers();
  var point;
  var currentLong;
  var currentLat;
 
  console.log("inside placeMarkers "+ currentLocation.toString());

  
                 
  console.log("locations inside ?"+params.points.length);
  for(var i in params.points) {
    latitude = params.points[i].lat;
    longitude = params.points[i].long;

    // console.log("current point in placeMarkers "+ currentLocation.latitude+","+currentLocation.longitude);
    

    if ( distLocation == 0) placeMarker(params.points[i].lat, params.points[i].long,0);
    else {
      point = new google.maps.LatLng(latitude, longitude);
      ////// Distance /////

      dist = google.maps.geometry.spherical.computeDistanceBetween(currentLocation, point )/1609;

      console.log("Distance "+ dist);

      if( distLocation == 0.5 && dist < 0.5 ) placeMarker(params.points[i].lat, params.points[i].long,dist);
      if( distLocation == 1 && dist < 1 ) placeMarker(params.points[i].lat, params.points[i].long,dist);
      if( distLocation == 2 && dist < 2 ) placeMarker(params.points[i].lat, params.points[i].long,dist);
      if( distLocation == 3 && dist < 3 ) placeMarker(params.points[i].lat, params.points[i].long,dist);
      if( distLocation == 4 && dist > 4 ) placeMarker(params.points[i].lat, params.points[i].long,dist);

    }

  }

  console.log("Panning to ...");
  map.panTo(new google.maps.LatLng(latitude, longitude));
//  google.maps.event.trigger(map,'resize');
//  showPageMarkers();
}

function clearMarkers() {
  for(var i in markers) {
    markers[i].setMap(null);
  }
  markers = [];
}

function placeMarker(lat, long,dist) {
  var i = markers.length;
  console.log("Marker index "+i);
  var marker = new google.maps.Marker({ //MarkerWithLabel({
    map: map,
    position: new google.maps.LatLng(lat,long),
    icon: "/assets/markers/marker_" + (i + 1) + ".png",
    index: i + 1
  });

  var boxText = document.createElement("div");
        boxText.style.cssText = "border: 1px solid black; margin-top: 8px; background: black;font-size: small; font-color: white;font-family: arial,sans-serif, padding: 5px;";
        
        if(dist == 0) boxText.innerHTML = '<font color="white"><strong>'+event_names[marker.index-1].name.toString().substring(0,25)+'</strong><br><i>'+venue_names[marker.index-1].name.substring(0,25)+'</i>'+'<br><i>'+event_descriptions[marker.index-1].description+'  '+'<button onclick="openSite('+event_ids[marker.index-1].id+')">Visit</button></i>';
        else boxText.innerHTML = '<font color="white"><strong>'+event_names[marker.index-1].name.toString().substring(0,25)+'</strong><br><i>'+venue_names[marker.index-1].name.substring(0,25)+'</i>'+'<br><i>'+event_descriptions[marker.index-1].description+'  Distance '+dist.toFixed(1)+'<button onclick="openSite('+event_ids[marker.index-1].id+')">Visit</button></i>';
                
        var myOptions = {
                 content: boxText
                ,disableAutoPan: true
                ,maxWidth: 0
                ,pixelOffset: new google.maps.Size(-140, 0)
                ,zIndex: null
                ,boxStyle: { 
                  background: "url('http://google-maps-utility-library-v3.googlecode.com/svn/trunk/infobox/examples/tipbox.gif') no-repeat"
                  ,opacity: 0.75
                  ,width: "200px"
                 }
                ,closeBoxMargin: "10px 2px 2px 2px"
                ,closeBoxURL: "http://www.google.com/intl/en_us/mapfiles/close.gif"
                ,infoBoxClearance: new google.maps.Size(1, 1)
                ,isHidden: false
                ,pane: "floatPane"
                ,enableEventPropagation: false
        };

        var ib = new InfoBox(myOptions);
        //ib.open(map, marker);

  google.maps.event.addListener(marker, 'click', function() {
    ib.open(map, marker);
    console.log("Event name "+event_names[marker.index-1].name.toString());
    console.log("Event description "+event_descriptions[marker.index-1].description.toString());
    console.log("Venue name "+venue_names[marker.index-1].name.toString());

  });
  google.maps.event.addListener(marker, 'dclick', function() {
   // $("#home .main .inner .events LI:nth-child(" + marker.index + ") .name").click();
   console.log("Marker double clicked "+event_ids[marker.index-1].id);
   
   window.open ('#event?event_id='+event_ids[marker.index-1].id,'_self',false);
  });
   markers.push(marker);
}

function openSite(event_id){
   window.open ('#event?event_id='+event_id,'_self',false);
}

function showVenue(urlObj, options) {
  var qrUrl = decodeURIComponent(urlObj.hash.replace(/.*event_id=/, ""));

  // The page we use to display QR code is already in the DOM. 
  // The id of the page we are going to write the content into is specified in the hash before the '?'.
  var pageSelector = urlObj.hash.replace(/\?.*$/, "");

  if (qrUrl) {
    console.log("venue id : "+qrUrl);
    var vUrl = decodeURIComponent(urlObj.hash.replace(/.*venue_id=/, ""));
    var pageSelector = urlObj.hash.replace(/\?.*$/, "");





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
              li.find("a").attr("href", "#event?event_id=" + event.id );
              li.find(".mod").html(mod);
              li.find(".day").html(day);
              li.find(".time").html(time);
              // li.find(".one a").attr("href",  "#event?event_id=" +event.id);
              li.find(".one span").html(event.title);
              //li.find(".one .description").html(event.description);
              if(event.price!=null)
                if(event.price!=0)
                  li.find(".one .description").html("<span ><strong>Price:  $" + parseFloat(event.price).toFixed(2) + "</strong></span> " + event.description.substring(0,25));
                else li.find(".one .description").html("<span><strong>Free</strong></span> " +event.description.substring(0,25));
              else li.find(".one .description").html(event.description.substring(0,25));
              li.appendTo('#venue .vevents-seed1');
            }
          
            $('#venue .vevents-seed1 li:not(:first-child)').each(function() {
              $(this).appendTo('#venue .vevents');
            });
          }

          // For occurrences
          if(occurrences.length > 0) {
            for (var i in occurrences){

              var event = occurrences[i].event;
              console.log("event name :"+event.title);
              var startTime = Date.parse(occurrences[i].start.substr(0,19));
              var dateString = startTime.toString("MMMdd").toUpperCase();
              
              li=$($('#venue .vevents-seed2 li:last-child').clone().wrap('<ul>').parent().html());
              li.find("a").attr("href", "#event?event_id=" + event.id );
              li.find(".mod").html(dateString);
              li.find(".day").html(day_of_week[occurrences[i].day_of_week]);
              li.find(".time").html(startTime.toString("hh:mmtt").toLowerCase());
              // li.find(".one a").attr("href",  "#event?event_id=" +event.id);
              li.find(".one span").html(event.title);
              //li.find(".one .description").html(event.description);
              if(event.price!=null)
                if(event.price!=0)
                  li.find(".one .description").html("<span ><strong>Price:  $" + parseFloat(event.price).toFixed(2) + "</strong></span> " + event.description.substring(0,25));
                else li.find(".one .description").html("<span><strong>Free</strong></span> " +event.description.substring(0,25));
              else li.find(".one .description").html(event.description.substring(0,25));
              li.appendTo('#venue .vevents-seed2');
            }
            
            $('#venue .vevents-seed2 li:not(:first-child)').each(function() {
              $(this).appendTo('#venue .vevents');
            });
          }

            $('#venue').show();    
            $('#venue .vevents-seed2').hide();
            $('#venue .vevents-seed1').hide(); 



       });




    var $page = $(pageSelector);

    // Get the header for the page.
    var $header = $page.children(":jqmData(role=header)");

    // Find the h1 element in the header and inject the hostname from the url.
    $header.find("h1").html(getHostname(qrUrl));
    // Make sure the url displayed in the the browser's location field includes parameters
    options.dataUrl = urlObj.href;

    // Now call changePage() and tell it to switch to the page we just modified.
    $.mobile.changePage($page, options);
  }


}
// Load the QR Code for a specific url passed in as a parameter.
// Generate markup for the page, and then make that page the current active page.
function showQRCode(urlObj, options) {
  // Get the url parameter
  var qrUrl = decodeURIComponent(urlObj.hash.replace(/.*event_id=/, ""));

  // The page we use to display QR code is already in the DOM. 
  // The id of the page we are going to write the content into is specified in the hash before the '?'.
  var pageSelector = urlObj.hash.replace(/\?.*$/, "");

  if (qrUrl) {
    // Get the page we are going to write content into.
    var $page = $(pageSelector);

    // Get the header for the page.
    var $header = $page.children(":jqmData(role=header)");

    // Find the h1 element in the header and inject the hostname from the url.
    $header.find("h1").html(getHostname(qrUrl));

    // Get the content area element for the page.
    
    $.getJSON('/events/show/' + qrUrl + '.json', function(event) {
            
            var startTime = Date.parse(event.occurrences[0].start.substr(0,19));
            var dateString = startTime.toString("dddd, MMMM d");

            $('#event_infos .time_one').html("<strong>"+dateString+"</strong>");
            $('#event_infos .time_two').html("<strong>"+startTime.toString("hh:mmtt")+"</strong>");
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

    var $content = $page.children(":jqmData(role=content)");

    
    // Inject the QR code markup into the content element.
    //$content.html("markup");
    // Make sure the url displayed in the the browser's location field includes parameters
    options.dataUrl = urlObj.href;

    // Now call changePage() and tell it to switch to the page we just modified.
    $.mobile.changePage($page, options);
  }
}

// Extract hostname from a url.
function getHostname(url) {
  return decodeURIComponent(url).replace(/.*\/\//, "").replace(/\/.*$/, "");
}
