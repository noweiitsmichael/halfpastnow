
var geocoder;
var map;
var markers = [];
var tags = {};
var channelFilters = {};

$(window).load(function() {
    if(typeof initialize !== 'undefined')
    initialize();
    });

function initialize() {
//console.log("initialize");
//$("#map").height($(window).height() - $("#map").offset().top - 2 * parseInt($("#map").css("border-top-width")));
    geocoder = new google.maps.Geocoder();

    var styles = [
    {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [
    { "color": "#804580" }
]
},{
    "featureType": "road.highway",
    "elementType": "labels.text.stroke",
    "stylers": [
    { "color": "#d5b5d5" }
]
},{
    "featureType": "road.arterial",
    "elementType": "labels.text.stroke",
    "stylers": [
    { "color": "#f1e6f3" }
]
},{
    "elementType": "geometry.fill",
    "stylers": [
    { "gamma": 1.54 },
                    { "lightness": 12 }
]
},{
    "featureType": "road.arterial",
    "elementType": "geometry.fill",
    "stylers": [
    { "color": "#e0dae0" }
]
},{
    "featureType": "road.arterial",
    "elementType": "geometry.stroke",
    "stylers": [
    { "color": "#b8abb8" }
]
},{
    "featureType": "road.highway",
    "elementType": "geometry.fill",
    "stylers": [
    { "color": "#af96af" }
]
},{
    }
];

var latlng = new google.maps.LatLng(30.268093, -97.742808);
var myOptions = {
    zoom: 13,
    center: latlng,
    mapTypeId: 'map_style',
    disableDefaultUI: true,
    zoomControl: true,
    scrollwheel: false,
    zoomControlOptions: { position: google.maps.ControlPosition.TOP_RIGHT, style: 2 },
backgroundColor: '#FFFFFF'
};

var styledMap = new google.maps.StyledMapType(styles,
                {name: "Styled Map"});

map = new google.maps.Map($("#googleMap")[0], myOptions);

        map.mapTypes.set('map_style', styledMap);
        map.setMapTypeId('map_style');

        var locations = [];

        $(".map_latlang").each(function(index) {
            var latitude = parseFloat($(this).find(".latitude").html());
            var longitude = parseFloat($(this).find(".longitude").html());
            locations.push({lat: latitude, long: longitude});
        });

        //console.log(locations);


        placeMarkers({points: locations});

//        google.maps.event.addListener(map, 'idle', boundsChanged);
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




