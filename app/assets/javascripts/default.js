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
          city = results[results.length-2].formatted_address;
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
  //var mins = TimeZoneDetect();
  var mins = new Date().getTimezoneOffset();
  var hours = Math.abs(Math.round( mins / 60));        
  var minutes = Math.abs(mins % 60);
  var offset;
  if (mins < 0) {
    offset = "+"+hours + ":" + minutes;
  } else {
    offset = "-"+hours + ":" + minutes;
  }
  $('#location_guess').html("We think you're in "+city+" (GMT"+offset+")");
  
  /*$.getJSON('https://maps.googleapis.com/maps/api/timezone/json?location='+latitude+','+longitude+'&timestamp=1331161200&sensor=false',function(j){
    $('#location_guess').html("We think you're in "+city+" ("+j.timeZoneId+")");
  });
$.ajax({

    url: 'https://maps.googleapis.com/maps/api/timezone/json?location='+latitude+','+longitude+'&timestamp=1331161200&sensor=false',
    type: 'GET',
    crossDomain: true,
    dataType: 'jsonp',
    success: function() { alert("Success"); },
    error: function() { alert('Failed!'); },
});
*/
}

function locationNotFound() {
  $('#location_guess').html("We can't find you. We'll put you in New York");
}
function TimeZoneDetect(){
    var dtDate = new Date('1/1/' + (new Date()).getUTCFullYear());
    var intOffset = 10000; //set initial offset high so it is adjusted on the first attempt
    var intMonth;
    var intHoursUtc;
    var intHours;
    var intDaysMultiplyBy;
 
    //go through each month to find the lowest offset to account for DST
    for (intMonth=0;intMonth < 12;intMonth++){
        //go to the next month
        dtDate.setUTCMonth(dtDate.getUTCMonth() + 1);
 
        //To ignore daylight saving time look for the lowest offset.
        //Since, during DST, the clock moves forward, it'll be a bigger number.
        /*if (intOffset > (dtDate.getTimezoneOffset() * (-1))){
            intOffset = (dtDate.getTimezoneOffset() * (-1));
        }*/
        if (!intOffset || intOffset > (dtDate.getTimezoneOffset() * (-1))){
          intOffset = (dtDate.getTimezoneOffset() * (-1));
        }
    }
 
    return intOffset;
}
