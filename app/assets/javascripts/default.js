
var locator =  function() {
  this.city = '';
  this.latitude = '';
  this.longitude = '';
  this.country = "UNITED STATES";
  this.sports_ui = '';
  this.geocoder = new google.maps.Geocoder();
  this.defaultOffset = 0;
  this.tz = '';
};
/* MOVED TO BE ANONYMOUS FUNCTION 
locator.prototype.successFunction = function(position) {
  latitude = position.coords.latitude;
  longitude = position.coords.longitude;

  myLocator.codeLatLng(latitude, longitude); // this should not call myLocator, it should be 'this' but the problem is this 'successFunction' is a CallBack and doesn't seem to send the whole object
};
*/

locator.prototype.codeLatLng = function(lat, lng) {
  var latlng = new google.maps.LatLng(lat, lng);
  var me = this;
  this.geocoder.geocode({'latLng': latlng}, function(results, status) {
      if (status == google.maps.GeocoderStatus.OK) {
      console.log(results)
      if (results[1]) {
      //formatted address
      me.city = results[results.length-2].formatted_address;
      me.country = results[results.length-1].formatted_address;
      me.locationFound();
      } else {
      me.locationNotFound();
      }
      } else {
      me.locationNotFound();
      //alert("Geocoder failed due to: " + status);
      }
      });
};

locator.prototype.successFunctionL = function() {
  this.codeLatLng(1,2);
}

locator.prototype.getMail = function () {  
  //this is a function on new instances of that object
  //whatever code you like
  return mail;
}

locator.prototype.otherMethod = function () { 
  //this is another function that can access obj.getMail via 'this'
  this.getMail();
}
//geocoder = new google.maps.Geocoder();
/* end geolocate stuff */

locator.prototype.locationFound = function() {
  /* As soon as locationFound, update left and middle columns */
  this.sports_ui.updateInitialEvents(this.country);
  this.sports_ui.updateTree(this.country); 

  //var mins = TimeZoneDetect();
  //var mins = new Date().getTimezoneOffset();
  var mins = this.TimeZoneDetect();
  var hours = Math.abs(Math.round( mins / 60));        
  var minutes = Math.abs(mins % 60);
  var offset;
  var offset_calc;
  var offset_no_dst;
  if (mins >= 0) {
    offset = "+"+hours + ":" + minutes;
    if (this.DSTActive()) {
      offset_no_dst = "+"+(hours-1)+":"+minutes;   
    } else {
      offset_no_dst = offset;
    }
  } else {
    offset = "-"+hours + ":" + minutes;
    if (this.DSTActive()) {
      offset_no_dst = "-"+(hours-1)+":"+minutes;   
    } else {
      offset_no_dst = offset;
    }
  }
  offset_dec = hours + minutes/60;
  this.defaultOffset = offset_dec;

  var timezone = jstz.determine();
  var tz = timezone.name(); 
  DST = this.DSTActive() ? " - Daylight Savings" : "";

  

 // $('#location_guess').html("We think you're in "+this.city+" ("+tz+" GMT"+offset+DST+")");
  this.sports_ui.set_tz_selector(tz.substring(tz.indexOf("/")+1), offset_no_dst);
  $('#user_time_zone').val(tz.split("/")[1]);
  mySportsUI.change_time_zone(offset_dec); 
  
  
  //$('#location_guess').html("Timezone: "+tz+" (GMT"+offset+")");

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
  };

locator.prototype.DSTActive = function() {
  var arr = [];
  for (var i = 0; i < 365; i++) {
    var d = new Date();
    d.setDate(i);
    newoffset = d.getTimezoneOffset();
    arr.push(newoffset);
  }
  DST = Math.min.apply(null, arr);
  nonDST = Math.max.apply(null, arr);
  return (DST != nonDST);
};

locator.prototype.locationNotFound = function() {
  $('#location_guess').html("We can't find you. We'll put you in New York");
};

locator.prototype.TimeZoneDetect = function(){
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

