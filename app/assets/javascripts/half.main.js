/** jquery plugins **/

// checks if element has a scrollbar

var toggle = false;
var toggleTag = false;
var toggleTime = false;
var toggleSort = false;

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
    // if ( $.browser.msie ) {
    //   var $textarea1 = $('<textarea cols="10" rows="2"></textarea>')
    //       .css({ position: 'absolute', top: -1000, left: -1000 }).appendTo('body'),
    //     $textarea2 = $('<textarea cols="10" rows="2" style="overflow: hidden;"></textarea>')
    //       .css({ position: 'absolute', top: -1000, left: -1000 }).appendTo('body');
    //   scrollbarWidth = $textarea1.width() - $textarea2.width();
    //   $textarea1.add($textarea2).remove();
    // } else {
      var $div = $('<div />')
        .css({ width: 100, height: 100, overflow: 'auto', position: 'absolute', top: -1000, left: -1000 })
        .prependTo('body').append('<div />').find('div')
          .css({ width: '100%', height: 200 });
      scrollbarWidth = 100 - $div.width();
      $div.parent().remove();
    // }
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
  var toggle = false;
  scrollbarWidth = $.getScrollbarWidth();
  var item_id;
  $('#content .events').on('click','li',function(event) {
    if ($(".edit-popup-box:visible").length > 0) {
      stopPropagation(event);
      $(".edit-popup-box").hide();
        var that = $('.edit-popup-box');
        if (that.hasClass("remove")) {
          that.removeClass('remove').addClass('add');
        }
    }
  });

  $('#content .main .inner.android .events').on('click','li',function(event) {
    stopPropagation(event);
    console.log("Open mobile");
    var id = $(this).attr('event-id');
    // http://www.halfpastnow.com/events/show/167474?fullmode=true
    var lnk = "http://www.halfpastnow.com/events/show/"+id+"?fullmode=true";
    console.log(lnk);
    
    window.open(lnk);
  });
  // Android : Control Popups
  
  $('#content ').on('click','.button-search-ad',function(event) {
    stopPropagation(event);
    // Get category tag ids & name
    var InvForm = document.getElementById("categories");
    var catIDs= "";
    for (x=0;x<InvForm.length;x++)
         {
            if(InvForm[x].selected)
            {
              var tmp = InvForm[x].value ; 
              catIDs = (catIDs=="") ? "included_tags="+tmp : catIDs+','+tmp ;
              
              

            }
         }
    
    InvForm = document.getElementById("tags");
    console.log("catIDsXXX: ");
    var andTags="";
    for (x=0;x<InvForm.length;x++)
         {
            if(InvForm[x].selected)
            {
              var tmp = InvForm[x].value; 
              if (x !==0) {
                andTags = (andTags=="") ? "and_tags="+tmp : andTags+','+tmp ;
              };
              
              
              

            }
         }
   
    console.log("catIDsA: ");
    var e = document.getElementById("dayAd");
    var day = e.options[e.selectedIndex].value;
   
    console.log("catIDsA: "+day);
    var dayString = "";
    if (day == 0) {
      dayString="start_days=0&end_days=-1&aday=0";
    }else if(day == 1){
      dayString="start_days=0&end_days=0&time=Today&aday=1";
    }else if(day == 2){
      dayString="start_days=1&end_days=1&time=Tomorrow&aday=2";
    }else if(day == 3){
      // var d = new Date();
      x=5;//d.getDay();
      if (x < 6 && x>0) { 
        dayString="start_days=0&end_days=7&days=0,6&time=Weekend&aday=3";
      }else if (x ==0 ) { 
        dayString="start_days=0&end_days=0&time=Weekend&aday=3";
      }else if (x ==6 ) { 
        dayString="start_days=0&end_days=1&time=Weekend&aday=3";
      };
    };
    
    e = document.getElementById("cost");
    var cost = e.options[e.selectedIndex].value;
    console.log("catIDs: cost"+cost);
    var costString = "";
    if (cost == 0) {
      costString = "low_price=0&high_price=777777777&c=0";
    }else if (cost == 1) {
      costString = "low_price=0&high_price=0&c=1";
    }else if (cost == 2) {
      costString = "low_price=0&high_price=10&c=2";
    }else if (cost == 3) {
      costString = "low_price=0&high_price=20&c=3";
    };
    e = document.getElementById("sortAd");
    var sort = e.options[e.selectedIndex].value;
    var sortString="sort=0";
    if (sort == 1) {
      sortString="sort=1";
    }
    else if (sort == 0) {
      sortString="sort=0";
    };

    console.log("In search-ad "+ costString);
    
    // console.log(catIDs + );
    var searchString = "/events/android?"+catIDs+"&"+andTags+"&"+dayString+"&"+costString+"&type=advance"+"&"+sortString;
    // alert(searchString);
     window.open(searchString,'_self');
  });

  $('#content ').on('click','.button-search',function(event) {
    stopPropagation(event);
    var e = document.getElementById("access");
    var access = e.options[e.selectedIndex].value;
    console.log(access);
    e = document.getElementById("time");
    var time = e.options[e.selectedIndex].value;
    e = document.getElementById("sort");
    var sort = e.options[e.selectedIndex].value;

    var InvForm = document.getElementById("tag");
    var SelBranchVal = "";
    var x = 0;
    var tag ="";
    console.log("Get Android status");
    console.log(document.getElementById("androidStatus").value);
     for (x=0;x<InvForm.length;x++)
         {
            if(InvForm[x].selected)
            {
              var tmp = InvForm[x].value; 
              if (tmp==0) {
                tag = (tag=="") ? "166" : tag +",166";
              }else if (tmp==1) {
                tag = (tag=="") ? "165" : tag +",165";
              }else if (tmp==2) {
                tag = (tag=="") ? "184" : tag +",184";
              }else if (tmp==3) {
                tag = (tag=="") ? "167" : tag +",167";
              }else if (tmp==4) {
                tag = (tag=="") ? "189" : tag +",189";
              }else if (tmp==5) {
                tag = (tag=="") ? "191" : tag +",191";
              };
              

            }
         }
   

    var accessString = "channel_id=414";
   
    if (access==0) {
      accessString="channel_id=414&access=0";
    }else if(access==1) {
      accessString="channel_id=415&access=1";
    }else if(access==2) {
      accessString="channel_id=416&access=2";
    }else if(access==3) {
      accessString="channel_id=424&access=4";
    };
    var tagString = (tag=="") ? "" :"included_tags="+tag;
    var sortString="sort=1";
    if (sort == 1) {
      sortString="sort=1";
    }
    else if (sort == 0) {
      sortString="sort=0";
    };

    var today = new Date();
    var dd = today.getDate();
    var mm = today.getMonth()+1; //January is 0!
    var yyyy = today.getFullYear();
    if(dd<10){
      dd='0'+dd;
    }; 
    if(mm<10){
      mm='0'+mm;
    }; 

    dd = yyyy+"-"+mm+"-"+dd
    var dateString = "start_days=&end_days=";
    if (time==0) { 
      dateString = "start_date="+dd+"&end_date=2013-03-17&t=0";
    }else if (time==1) { 
      dateString = "start_days=0&end_days=0&t=1";
    }else if (time==2) { 
      dateString = "start_date="+dd+"&end_date=2013-03-12&t=2";
    }else if (time==3) { 
      dateString = "start_date="+dd+"&end_date=2013-03-16&t=3";
    }else if (time==4) { 
      dateString = "start_date="+dd+"&end_date=2013-03-17&t=4";
    };

    var searchString = "/events/android?"+accessString+"&"+tagString+"&"+sortString+"&"+dateString+"&type=sxsw";
    console.log(searchString);
    window.open(searchString,'_self');
    
    


  });

  $('#content .events').on('click','.addthisevent-drop',function(event) {
    stopPropagation(event);
  });
  $('#content .events').on('click','.picklists .picklist-link',function(event) {
    stopPropagation(event);
  });
  $('#content .events').on('click','.rsvp-button',function(event) {
    stopPropagation(event);
  });
  $('#content .events').on('click','.edit-popup-box',function(event) {
    stopPropagation(event);
  });
  $('#content .events').on('click','.edit-label',function(event) {
    stopPropagation(event);
  });
  $('#content .events').on('click','.edit-button',function(event) {
    stopPropagation(event);
   
  });
  $('#content .events').on('click','.edit-comment-text',function(event) {
    stopPropagation(event);
  });

  $("body").click
  (
    function(e)
    {
      if(e.target.className !== "edit-popup-box")
      {
        $(".edit-popup-box").hide();
        var that = $('.edit-popup-box');
        if (that.hasClass("remove")) {
          that.removeClass('remove').addClass('add');
        }

      }
    }
  );

  $('#content .events').on('click','.edit-add-tp',function(event) {
    stopPropagation(event);
    var id = $(this).attr('event-id');
    var item='.'+id+' '+'.edit-popup-box';
    var item1='.'+id+' '+'.edit-popup-box-1';
    // console.log("Comment Edit "+item);
    item_id=id;
    var that = $(item);
    var that1= $(item1);
    if (that.hasClass("add")){
        that.removeClass('add').addClass('remove');
        that.show();
        that1.hide();
        
      }
      else if (that.hasClass("remove")) {
        that.removeClass('remove').addClass('add');
        that.hide();
        that1.show();
      }
  });

  $('#content .events').on('click','.delete-tp',function(event) {
    stopPropagation(event);
    var id = $(this).attr('event-id');
    $.getJSON('/bookmarks/destroyBookmarkedList/' + id, function(data) {
              
            });

    // document.getElementById(id).parentNode.remove();
    $(this).parents("#content .events li").html("<div><br><br><br>Top Pick Removed</div>");
  });
  
  
  $('#content .events').on('click','.event-actions .icon',function(event) {
    var that = $(this);
    var id = $(this).attr('event-id');
    var title = $(this).attr('event-title');
    var summary = $(this).attr('event-summary');
    var pic = $(this).attr('event-pic');
    var app_id = "475386955806720";
    var redirect = "http://www.halfpastnow.com";
    var venue = $(this).attr('event-venue');
    var type = "event";
    var root_url = encodeURIComponent(window.location.origin);
    var link = root_url + "/events/show/" + id + "?fullmode=true";
    var facebook_url = "http://www.halfpastnow.com/events/show/" + id + "?fullmode=true";

    var html_title = title.replace(/[%|&\/#"\\]/g, function(m) {
          return (m === '"' || m === '\\') ? " " : "%" + m.charCodeAt(0).toString(16);
    });
    var html_venue = venue.replace(/[%|&\/#"\\]/g, function(m) {
          return (m === '"' || m === '\\') ? " " : "%" + m.charCodeAt(0).toString(16);
    });

    console.log(html_title);
    console.log(venue);
    console.log(link);
    
    if($(this).hasClass('facebook')) {
      console.log(facebook_url);
      // var url = "https://www.facebook.com/dialog/feed?%20app_id=" + app_id + "&%20link=" + link + "&%20picture=" + pic + "&%20name=" + title + "&%20caption=" + venue + "&%20description=" + summary + "&%20redirect_uri=" + redirect;
      var url = "http://www.facebook.com/sharer.php?u=" + facebook_url;
      window.open(url, '_blank');
      window.focus();
      stopPropagation(event);
    } else if($(this).hasClass('twitter')) {
      console.log(title.replace(/(<([|^>]+)>)/ig,"").replace(/&/ig,"and"));
      var url = 'http://twitter.com/intent/tweet?text=' + title.replace(/(<([|^>]+)>)/ig,"").replace(/&/ig,"and").substring(0,50) + ' ' + link + ' @halfpastnow %23discoveraustin';
      window.open(url, '_blank');
      window.focus();
      stopPropagation(event);
    } else if($(this).hasClass('email')) {
      var url = 'mailto:?subject=Check out this event&body=Take a look at this event: %0D%0A%0D%0A' + html_title + '%0D%0A' + 'at ' + venue + '%0D%0A%0D%0A' + link + '%0D%0Avia http://www.halfpastnow.com';
      window.open(url, '_blank');
      window.focus();
      stopPropagation(event);
    } else if($(this).hasClass('bookmark')) {

      console.log(title);
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
                  
        var lnk = 'http://www.halfpastnow.com/events/show/'+id+'?fullmode=true'; 
        // var lnk = 'http://wwww.halfpastnow.com/events/show/'+id+'?fullmode=true'; 
        // var lnk = 'http://www.halfpastnow.com/mobile/og/'+id; 
        console.log(lnk);

        FB.api(
            '/me/halfpastnow:bookmark',
            'post',
            { event: lnk },
            function(response) {
               if (!response || response.error) {
                  // alert('Error occured'+response);
               } else {
                  // alert('Post list was successful! Action ID: ' + response.id);
               }
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

  // This "attending" class won't be here if the user isn't logged in
  $('#content .events').on('click','.attending',function(e) {
    var occurrenceId = $(this).attr('occ-id');
    var that = $(this);
    if(that.hasClass('add')) {
      var bookmarked_type = "Occurrence";
      var lnk = 'http://www.halfpastnow.com/events/show/'+occurrenceId+'?fullmode=true'; 
          console.log("Attend: "+lnk);
          FB.api(
                  '/me/halfpastnow:attend',
                  'post',
                  { event: lnk },
                  function(response) {});
      $.getJSON('/bookmarks/attending_create', { bookmark: { "type": bookmarked_type, "id": occurrenceId } }, function(data) {
        console.log("new attending bookmark");
        that.removeClass('add').addClass('remove');
        that.text("RSVP'd");
        attending_id = data;
      });
    } 
    else if(that.hasClass('remove')) {
         e.preventDefault();
       $.getJSON('/bookmarks/destroy/' + attending_id, function(data) {
              that.addClass('add').removeClass('remove');
        that.text("RSVP");
        $(".re-rsvp").text("");
          });
    }
  });

  
});

function defaultTo(parameter, parameterDefault) {
  return (typeof parameter !== 'undefined' && parameter !== null) ? parameter : parameterDefault;
}

$(function() {

  if(window.location.href.indexOf("users") === -1) {
    $('#content').on("mouseenter", ".events > li:not(.no-results)", function() {
      google.maps.event.trigger(markers[$(this).index()], 'mouseover');
    });

    $('#content').on("mouseleave", ".events > li:not(.no-results)", function() {
      google.maps.event.trigger(markers[$(this).index()], 'mouseout');
    });

    $('#body').scroll(showPageMarkers);
    $('#body').scroll(scrollHeader);
  }
  
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
  var timer;
  var marker = new google.maps.Marker({ //MarkerWithLabel({
    map: map,
    position: new google.maps.LatLng(lat,long),
    icon: "/assets/markers/marker_" + (i + 1) % 100 + ".png",
    index: i + 1
  });

  //** Gotta check to see if the infobox exists first so that we don't end up making a bajillion hidden infoboxes
  // *** Took out infobox stuff for now
  google.maps.event.addListener(marker, 'mouseover', function() {
    // clearTimeout($(".infobox_" + marker.index).data('timeoutId'));
    marker.setIcon("/assets/markers/marker_hover_" + marker.index % 100 +  ".png");
    marker.setZIndex(9999);
    $("#content .main .inner .events li:nth-child(" + marker.index + ")").addClass("hover");
    // if ($(".infobox_" + marker.index).length === 0) {
    //   var infobox = new SmartInfoWindow({
    //       position: marker.getPosition(), 
    //       map: map, 
    //       number: marker.index,
    //       content: "<div style='padding-left: 5px; font-size: 12px; color: #6F376F; font-style: italic; font-weight:900'>" + 
    //                   $("#content .main .inner .events li:nth-child(" + marker.index + ") .title").html().substring(0,40)+"..." + 
    //                "</div>" + 
    //                "<div style='padding-left: 5px; font-size: 14px; color: #6F376F; font-weight:900; font-variant: small-caps; text-transform: lowercase'>" + 
    //                   "@ " + $("#content .main .inner .events li:nth-child(" + marker.index + ") .venue-inner").html().substring(0,30)+"..." + 
    //                "</div>" + 
    //                "<div style='padding-left: 5px; font-size: 12px; font-weight:700; text-transform: lowercase'>" + 
    //                   $("#content .main .inner .events li:nth-child(" + marker.index + ") .datetime").html() + 
    //                "</div>"
    //   });
    // } else {
    //   if ($("#content .main .inner .events li:nth-child(" + marker.index + ")").hasClass("hover")) {
    //     $(".infobox_" + marker.index).show();
    //   } else {
    //     $(".infobox_" + marker.index).hide();
    //   }
    // }
  });

  // The timeout thing acts as a debounce and also allows time to enter the infobox before hiding it
  google.maps.event.addListener(marker, 'mouseout', function() {
    marker.setIcon("/assets/markers/marker_" + marker.index % 100 + ".png");
    marker.setZIndex(0);
    $("#content .main .inner .events li:nth-child(" + marker.index + ")").removeClass("hover");

    // var timeoutId = setTimeout(function(){
    //   $(".infobox_" + marker.index).hide();
    // }, 50);
    // $(".infobox_" + marker.index).data('timeoutId', timeoutId); 
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
    start -= fuzz; end += (fuzz + 15);
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
    $('#sxsw-wrap').width($('#body').width() - scrollbarWidth);

  } else {
    //$('#map-wrapper').width(mapWrapperWidth + scrollbarWidth);
    $('#header').width($('#body').width());
    $('#sxsw-wrap').width($('#body').width() - scrollbarWidth);
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
      addthisevent.refresh();
      $('.addthisevent_dropdown').hide();
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


var toggle = false;
  var item_id;
  function show(id) {
    console.log("Hovering"+id);
     var item = '.event-tp-comment-id';
     $(id).show();
  }
    function hide(id) {
      console.log("Out Hovering"+id);
      // document.getElementById(id).style.visibility = "hidden";
       $(id).hide();
    }

    function addToFeaturedList(id)
      { 
        var itemText='.'+id+' '+'.edit-popup-box-1 .edit-comment-text';
        var item='.'+id+' '+'.edit-popup-box-1';
        var that = $(item);
      if (that.hasClass("add")){
          $(item).removeClass('add').addClass('remove');
          $(item).show();
        }
        else if ($(item).hasClass("remove")){
          $(item).removeClass('remove').addClass('add');
          $(item).hide();
        }
        var text = $('.edit-comment-text').val();
        
        
        $.getJSON('/bookmarks/add_to_featuredlist', { bookmark: { "type": "Occurrence", "id": id , "comment":text } }, function(data) {
          bookmark_id = data;
        });
      
        
      }

    function submit_edit_comment(id)
      { 
        var itemText='.'+id+' '+'.edit-popup-box .edit-comment-text';
        var text = $(itemText).val();
        var item='.'+id+' '+'.edit-popup-box';
      console.log("Edit comment"+text);
      $.getJSON('/bookmarks/update_comment', { bookmark: { "type": "Occurrence", "id": id, "comment": text } }, function(data) {
            bookmark_id = data;
            
        });
       
      console.log("Comment EEdit "+item);
      var that = $(item);
      if (that.hasClass("add")){
          $(item).removeClass('add').addClass('remove');
          $(item).show();
        }
        else if ($(item).hasClass("remove")){
          $(item).removeClass('remove').addClass('add');
          $(item).hide();
        }
       item = '.'+id;
       document.getElementById(id).innerHTML = text;
       
       
    }
    function deleteTP(id)
      { 
        var itemText='.'+id+' '+'.edit-popup-box .edit-comment-text';
        var item='.'+id+' '+'.edit-popup-box';
        var that = $(item);
      if (that.hasClass("add")){
          $(item).removeClass('add').addClass('remove');
          $(item).show();
        }
        else if ($(item).hasClass("remove")){
          $(item).removeClass('remove').addClass('add');
          $(item).hide();
        }
        $.getJSON('/bookmarks/destroyBookmarkedList/' + id, function(data) {
              that.removeClass('remove').addClass('add');
            });
        document.getElementById(id).parentNode.innerHTML = "<div><br><br><br>Top Picked Removed</div>";
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
