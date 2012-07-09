// Listen for any attempts to call changePage().
$(document).bind("pagebeforechange", function(e, data) {
  // We only want to handle changePage() calls where the caller is asking to load a page by URL.
  if (typeof data.toPage === "string") {
    // We only want to handle #qrcode url.
    var u = $.mobile.path.parseUrl(data.toPage);
    var qrcode = /^#event/;
    var vcode = /^#venue/;
    console.log("toPage : "+ data.toPage);
    if (u.hash.search(qrcode) !== -1) {
      // Display QR code for the selected URL.
      showQRCode(u, data.options);
      e.preventDefault();
    }
    if (u.hash.search(vcode) !== -1) {
      // Display QR code for the selected URL.
      showVenue(u, data.options);
      e.preventDefault();
    }
  }
});
var hours = ['midnight','1 am','2 am','3 am','4 am','5 am','6 am','7 am','8 am','9 am','10 am','11 am','noon','1 pm','2 pm','3 pm','4 pm','5 pm','6 pm','7 pm','8 pm','9 pm','10 pm','11 pm','midnight'];

var day_of_week = ['SUN','MON','TUE','WED','THU','FRI','SAT'];
function to_ordinal(num) {
   
    var ordinal = ["th","st","nd","rd","th","th","th","th","th","th"] ;
    return num.toString() + ordinal[num%10];
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

          // For occurrences
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
            start = new Date(event.occurrences[0].start);
            console.log("Json called " + event.title);
            console.log("description " + event.description);
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