
// This is where all the page initialisation happens.
$(document).ready(function () {
  // first locate
  if (navigator.geolocation) { navigator.geolocation.getCurrentPosition(successFunction, locationNotFound); } 
  
  // then fill out left menu 

  // then fill out center menu
});
function updateEvents(country) {
  $.getJSON( '/country/leagues/'+country+'.json',
  { },
  function(events) {
    var start_date_utc, start_date_local;
    //for (i=0;i<leagues.length;i++) {
      // l =  leagues[i];
      for (j=0;j<events.length;j++) {
        e = events[j];
        if (e.teams.length==2) {
          start_date_utc = new Date(e.start_date);
          start_date_local = start_date_utc.toString('ddd hh:mmtt'); 
          $("#list1 ").append('<li class="ui-li ui-li-static ui-btn-up-c"><p class="ui-li-aside ui-li-desc"><strong>'+e.time_in_words+'</strong> <sup>'+start_date_local+'</sup></p>'+e.league+' - '+e.teams[0].name + ' vs ' + e.teams[1].name +' </li>')
          //            $('#events').append(j+"  :"+e.league.name + " - ");  
          //           $('#events').append("  >>"+e.teams[0].name + " vs " + e.teams[1].name );  
          //          $('#events').append(" start: "+e.start_date+"<br />");  
          }
        }
        //}
      $.mobile.loading('hide');
    }); 
}

function updateTree() {
  $.getJSON( '/leagues/country/'+country+'.json',
  { },
  function(leagues) {
      for (i=0;i<leagues.length;i++) {
        if (i ==0 ) { 
          $('#main_sports_list').append('<h5>'+leagues[i].sport+'</h5>');
          $('#main_sports_list').append('<ul>');
        } else {
          if (leagues[i].sport != leagues[i-1].sport) {
            $('#main_sports_list').append('</ul>');
            $('#main_sports_list').append('<h5>'+leagues[i].sport+'</h5>');
            $('#main_sports_list').append('<ul>');
          }
        }
          $('#main_sports_list').append('<li>'+leagues[i].name+'<input type=checkbox checked align=right></li>');

          //$("#list1 ").append('<li class="ui-li ui-li-static ui-btn-up-c"><p class="ui-li-aside ui-li-desc"><strong>'+e.time_in_words+'</strong></p>'+e.league+' - '+e.teams[0].name + ' vs ' + e.teams[1].name +' </li>')
          //            $('#events').append(j+"  :"+e.league.name + " - ");  
          //           $('#events').append("  >>"+e.teams[0].name + " vs " + e.teams[1].name );  
          //          $('#events').append(" start: "+e.start_date+"<br />");  
        }
          $('#main_sports_list').append('</ul>');
      
        //}
    }); 
}

function localize(t)
{
  var d=new Date(t+" UTC");
  document.write(d.toString());
}
