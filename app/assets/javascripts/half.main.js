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

var baseModality = { internal_url: function() { return "/" + this.type + "s/show/" + this.id; },
                     url: function() { return "?" + this.type + "_id=" + this.id; } };

var modalities = {
  "venue": spawn(baseModality, {type: "venue"}),
  "event": spawn(baseModality, {type: "event"}),
  "act": spawn(baseModality, {type: "act"}),
  "shunt": spawn(baseModality, {type: "shunt", internal_url: function() { return "/events/shunt"; }, url: function() { return "?shunt"; }}),
  "new-channel": spawn(baseModality, {type: "new-channel", internal_url: function() { return "/channels/new"; }, url: function() { return "?new-channel"; }}),
  "new-channel-2": spawn(baseModality, {type: "new-channel-2", internal_url: function() { return "/channels/new2"; }, url: function() { return "?new-channel-2"; }})
};


  
 
$(function() {

  scrollbarWidth = $.getScrollbarWidth();

  $('#content .events').on('click','.event-actions .icon',function(event) {
    var that = $(this);
    var id = $(this).attr('event-id');
    var type = "event";
    var root_url = encodeURIComponent(window.location.origin);
    var link = root_url + "%3F" + type + "_id%3D" + id;
    
    if($(this).hasClass('facebook')) {
      var url = 'http://www.facebook.com/sharer/sharer.php?u=' + link;
      window.open(url, '_blank');
      window.focus();
      stopPropagation(event);
    } else if($(this).hasClass('twitter')) {
      var url = 'https://twitter.com/intent/tweet?text=' + link;
      window.open(url, '_blank');
      window.focus();
      stopPropagation(event);
    } else if($(this).hasClass('email')) {
      var url = 'mailto:?body=' + link;
      window.open(url, '_blank');
      window.focus();
      stopPropagation(event);
    } else if($(this).hasClass('bookmark')) {
      var bookmark_id = that.attr('bookmark-id');
      if(that.hasClass('add')) {


      window.fbAsyncInit = function() {
        console.log("Loaded FB 2");
          FB.init({
            appId      : '475386955806720', // App ID
            status     : true, // check login status
            cookie     : true, // enable cookies to allow the server to access the session
            xfbml      : true  // parse XFBML
          });
        };

        // Load the SDK Asynchronously
        (function(d){
          var js, id = 'facebook-jssdk'; if (d.getElementById(id)) {return;}
          js = d.createElement('script'); js.id = id; js.async = true;
          js.src = "//connect.facebook.net/en_US/all.js";
          d.getElementsByTagName('head')[0].appendChild(js);
        }(document));// delete below
        
        




        console.log('Bookmark outside');
        var lnk = 'http://halfpastnow.com/?event_id='+id;
        console.log(lnk);
        FB.api(
            '/me/hpnevent:bookmark',
            'post',
            { event: lnk },
            function(response) {
               // if (!response || response.error) {
               //    alert('Error occured'+response);
               // } else {
               //    alert('Post list was successful! Action ID: ' + response.id);
               // }
            });
        $.getJSON('/bookmarks/custom_create', { bookmark: { "type": "Occurrence", "id": id } }, function(data) {
          bookmark_id = data;
          that.attr('bookmark-id',bookmark_id);
          that.removeClass('add').addClass('remove');
        });
      } else {
        $.getJSON('/bookmarks/destroy/' + bookmark_id, function(data) {
          that.addClass('add').removeClass('remove');
        });
      }
      stopPropagation(event);
    }
  });

  
});

function defaultTo(parameter, parameterDefault) {
  return (typeof parameter !== 'undefined') ? parameter : parameterDefault;
}

$(function() {

  $('#content').on("mouseenter", ".events > li:not(.no-results)", function() {
    google.maps.event.trigger(markers[$(this).index()], 'mouseover');
  });

  $('#content').on("mouseleave", ".events > li:not(.no-results)", function() {
    google.maps.event.trigger(markers[$(this).index()], 'mouseout');
  });

  $('#body').scroll(showPageMarkers);
  $('#body').scroll(scrollHeader);
  
  $(window).resize(showPageMarkers);
  $(window).resize(checkScroll);
  $(window).resize(scrollHeader);

  $("html").on("click", "[linkto]", loadModal);
  //$("#header").on("click", "[linkto]", loadModal);
  //$('#overlays').on("click", "[linkto]", loadModal);
  $('#overlays').on("click", '.mode .close-btn', closeMode);

  $('.mode .overlay .background').click(closeMode);

  checkScroll();
});

$(window).load(function() {
  if(typeof initialize !== 'undefined')
    initialize();
});

function scrollHeader() {
  // var headerTop = -(Math.min($('#body').scrollTop(),$('#header .one').outerHeight()));
  // $('#header, #content #map-wrapper').css('top',headerTop+'px');
}

window.addEventListener("popstate", function(e) {
  var state = history.state;
  if(state && state.type) {
    var modality = spawn(modalities[state.type],{id: state.id});
    modal(modality);
  } else {
    demodal();
  }
});

function closeMode() {
  //console.log("closeMode");
  //window.History.pushState({}, /* "main mode" */ null, "/");
  console.log(window.location);
  history.pushState({ }, /* "main mode" */ "what is this even for", window.location.pathname);
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
    icon: "/assets/markers/marker_" + (i + 1) % 100 + ".png",
    index: i + 1
  });

  google.maps.event.addListener(marker, 'mouseover', function() {
    marker.setIcon("/assets/markers/marker_hover_" + marker.index % 100 +  ".png");
    $("#content .main .inner .events li:nth-child(" + marker.index + ")").addClass("hover");
  });

  google.maps.event.addListener(marker, 'mouseout', function() {
    marker.setIcon("/assets/markers/marker_" + marker.index % 100 + ".png");
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

function stopPropagation(event) {
  if (event && event.stopPropagation) {
    event.stopPropagation();
  } else if (window.event) {
    window.event.cancelBubble = true;
  }
}

function loadModal(event) {
  var modality = spawn(modalities[$(this).attr("linkto")],{id: $(this).attr("link-id")});
  if($(this).attr("linkto") !== "shunt" && $(this).attr("linkto") !== "new-channel" && $(this).attr("linkto") !== "new-channel-2" ) {
    history.pushState({ "type": modality.type, "id": modality.id }, "test", modality.url());
  }
  if($(this).is("#content .main .events li .venue")) {
     stopPropagation(event);
  }
  modal(modality);
  return false;
}

//only works for one parameter. lol.
function parsequery(query) {
  query = query.substring(1, query.length);
  var queryArr = query.split('=');
  if(queryArr[0] == "venue_id") {
    return spawn(modalities["venue"],{ id: queryArr[1] });
  } else if(queryArr[0] == "event_id") {
    return spawn(modalities["event"],{ id: queryArr[1] });
  } else if(queryArr[0] == "act_id") {
    return spawn(modalities["act"],{ id: queryArr[1] });
  } else if(queryArr[0] == "shunt") {
    return spawn(modalities["shunt"]);
  } else if(queryArr[0] == "new-channel") {
    return spawn(modalities["new-channel"]);
  } else {
    return null;
  }
}

function demodal() {
  modal();
}

function strip(html) {
  var tmp = document.createElement("DIV");
  tmp.innerHTML = html;
  return tmp.textContent || tmp.innerText;
}

function modal(modality) {
  if(!modality) {
    $('.mode').hide();
    $('.mode .insert-point').html("");
    return;
  } else {
    $.get(modality.internal_url(), function(data) {
      $('.mode').hide().removeClass().addClass('mode ' + modality.type);
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














// function pushThatState(event) {

//   /*
//   * get event object from window event, needed for Internet Explorer < 9
//   */
//   event = event || window.event;

//   // prevented default event
//   if ( event.preventDefault ) {
//     event.preventDefault();
//   } else {
//     event.returnValue = false;
//   }

//   var title,
//       // get target element
//       target = event.target || event.srcElement;
  
//   if (target.nodeName == 'A') {
//     title = target.innerHTML;
//     data[title].url = target.getAttribute('href', 2); // slightly hacky (the setting), using getAttribute to keep it short
//     history.pushState(data[title], title, target.href);
//     console(data[title]);
//   }
// }

// addEvent(window, 'popstate', function (event) {

//   /*
//   * get event object from window event, needed for Internet Explorer < 9
//   */
//   event = event || window.event;

//   /*
//   * if you want to get the current location is generated must be taken of the event
//   *
//   * for example:
//   *
//   * var currentLocation = event.location || document.location;
//   */

//   var data = event.state;
//   console.log("popstate");
//   console.log(event);
//   console.log(event.state);
// });

// addEvent(window, 'hashchange', function (event) {
//   console.log("hashChange");
//   console.log(event);

//   // we won't do this for now - let's stay focused on states
//   /*
//   if (event.newURL) {
//     urlhistory.innerHTML = event.oldURL;
//   } else {
//     urlhistory.innerHTML = "no support for <code>event.newURL/oldURL</code>";
//   }
//   */
// });

// addEvent(window, 'pageshow', function (event) {
//   console.log("pageshow");
//   console.log(event);
// });

// addEvent(window, 'pagehide', function (event) {
//   console.log("pagehide");
//   console.log(event);
// });
