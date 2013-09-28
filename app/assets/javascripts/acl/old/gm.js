function initialize()
{
var mapProp = {
  center:new google.maps.LatLng(30.268505,-97.739697),
  zoom:14,
  mapTypeId:google.maps.MapTypeId.ROADMAP
  };
var map=new google.maps.Map(document.getElementById("googleMap"),mapProp);
}

google.maps.event.addDomListener(window, 'load', initialize);
