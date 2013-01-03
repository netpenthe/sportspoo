/* start geolocate stuff */
var geocoder;
var city;
var latitude;
var longitude;

if (navigator.geolocation) {
  navigator.geolocation.getCurrentPosition(successFunction, locationNotFound);
} 
//Get the latitude and the longitude;
function successFunction(position) {
  latitude = position.coords.latitude;
  longitude = position.coords.longitude;
  codeLatLng(latitude, longitude)
}

function codeLatLng(lat, lng) {
  var latlng = new google.maps.LatLng(lat, lng);
  geocoder.geocode({'latLng': latlng}, function(results, status) {
      if (status == google.maps.GeocoderStatus.OK) {
        console.log(results)
        if (results[1]) {
          //formatted address
          city = results[results.length-1].formatted_address;
          locationFound();
        } else {
          locationNotFound();
        }
      } else {
        locationNotFound();
        //alert("Geocoder failed due to: " + status);
      }
  });
}
geocoder = new google.maps.Geocoder();
/* end geolocate stuff */

function locationFound() {
  $('#location_guess').html("We think you're in "+city);
  $.getJSON('https://maps.googleapis.com/maps/api/timezone/json?location='+latitude+','+longitude+'&timestamp=1331161200&sensor=false',function(j){
    $('#location_guess').html("We think you're in "+city+" ("+j.timeZoneId+")");
  });
}

function locationNotFound() {
  $('#location_guess').html("We can't find you. We'll put you in New York");
}
