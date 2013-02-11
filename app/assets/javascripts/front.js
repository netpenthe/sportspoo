
// This is where all the page initialisation happens.
$(document).ready(function () {
  // first locate
  if (navigator.geolocation) { navigator.geolocation.getCurrentPosition(successFunction, locationNotFound); } 
  
  // then fill out left menu 

  // then fill out center menu
});
function updateEvents(country) {
  $.getJSON( '/country/events/'+country+'.json',
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
          $("#list1 ").append('<li class="ui-li ui-li-static ui-btn-up-c" timestamp="'+start_date_utc.getTime()+'"><p class="ui-li-aside ui-li-desc"><strong>'+e.time_in_words+'</strong> <sup>'+start_date_local+'</sup></p>'+e.league+' - '+e.teams[0].name + ' vs ' + e.teams[1].name +' </li>')
          //            $('#events').append(j+"  :"+e.league.name + " - ");  
          //           $('#events').append("  >>"+e.teams[0].name + " vs " + e.teams[1].name );  
          //          $('#events').append(" start: "+e.start_date+"<br />");  
          }
        }
        //}
      //$.mobile.loading('hide');
    }); 
}

function getEvents(cb,league_id) {
  if (!cb.checked) { // hide all events for this league
    $('.league_id_'+league_id).fadeOut(1000);
  } else {
    $.getJSON( '/leagues/events/'+league_id+'.json',
    { },
    function(events) {
      var start_date_utc, start_date_local, timestamp;
      for (var i=0;i<events.length;i++) {
        e = events[i];
        if (e.teams.length==2) {
          start_date_utc = new Date(e.start_date);
          start_date_local = start_date_utc.toString('ddd hh:mmtt'); 
          timestamp = start_date_utc.getTime();

/*
        $('#list1 li').each(function(index) {
          var foo = $('#list1 li')[index];
          if (parseInt(foo.getAttribute("timestamp")) <= timestamp) {
            if (parseInt(foo.getAttribute("timestamp")) <= timestamp) {
              $("#list1").append('<li class="ui-li ui-li-static ui-btn-up-c"><p class="ui-li-aside ui-li-desc"><strong>'+e.time_in_words+'</strong> <sup>'+start_date_local+'</sup></p>'+e.league+' - '+e.teams[0].name + ' !!!!vs ' + e.teams[1].name +' </li>')
            }
            //$("#list1 li")[j].insertBefore('<li class="ui-li ui-li-static ui-btn-up-c"><p class="ui-li-aside ui-li-desc"><strong>'+e.time_in_words+'</strong> <sup>'+start_date_local+'</sup></p>'+e.league+' - '+e.teams[0].name + ' !!!!vs ' + e.teams[1].name +' </li>')
            //break;
          }
 
        });*/
         for (var j = $('#list1 li').length-1;j>=0;j--) {
          var list_item = $('#list1 li')[j];
          if (parseInt(list_item.getAttribute("timestamp")) <= timestamp) {
            $('<li class="ui-li ui-li-static ui-btn-up-c league_id_'+league_id+'"><p class="ui-li-aside ui-li-desc"><strong>'+e.time_in_words+'</strong> <sup>'+start_date_local+'</sup></p>'+e.league+' - '+e.teams[0].name + '  vs ' + e.teams[1].name +' </li>').hide().insertAfter($("#list1 li:nth-child("+j+")")).effect("highlight", {}, 1500);;
            //$("#list1 li:nth-child("+j+")").insertAfter('<li class="ui-li ui-li-static ui-btn-up-c"><p class="ui-li-aside ui-li-desc"><strong>'+e.time_in_words+'</strong> <sup>'+start_date_local+'</sup></p>'+e.league+' - '+e.teams[0].name + ' !!!!vs ' + e.teams[1].name +' </li>')
            //$("#list1 li")[j].insertBefore('<li class="ui-li ui-li-static ui-btn-up-c"><p class="ui-li-aside ui-li-desc"><strong>'+e.time_in_words+'</strong> <sup>'+start_date_local+'</sup></p>'+e.league+' - '+e.teams[0].name + ' !!!!vs ' + e.teams[1].name +' </li>')
            break;
          }
         }
        }
      }
    });
  }
}

function updateTree() {
  $.getJSON( '/country/leagues/'+country+'.json',
  { },
  function(leagues) {
    var theres_more = false;
    for (i=0;i<leagues.length;i++) {
      if (i ==0 ) { 
        $('#main_sports_list').append('<h5>'+leagues[i].sport+'</h5>');
        $('#main_sports_list').append('<ul>');
      } else {
        if (leagues[i].sport != leagues[i-1].sport) {
          if (theres_more) {
            $('#main_sports_list').append('<li><a href="#" onclick="$(\'.tree_league_id_'+leagues[i-1].sport_id+'\').fadeIn()">show more...</a></li>');
            theres_more = false;
          }
          $('#main_sports_list').append('</ul>');
          $('#main_sports_list').append('<h5>'+leagues[i].sport+'</h5>');
          $('#main_sports_list').append('<ul>');
        }
      }

      switch (leagues[i].priority) {
        case 1:
          $('#main_sports_list').append('<li>'+leagues[i].name+'11<input type=checkbox align=right onclick="getEvents(this, '+leagues[i].id+')"></li>');
          break;
        case 2:
          theres_more = true;
          $('#main_sports_list').append('<li class="league_hidden tree_league_id_'+leagues[i].sport_id+'">'+leagues[i].name+'22<input type=checkbox id='+leagues[i].sport_id+' onclick="getEvents(this,'+leagues[i].id+')" align=right></li>');
          break;
        default:
          $('#main_sports_list').append('<li>'+leagues[i].name+'<input type=checkbox checked align=right></li>');
          break;
      }

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
