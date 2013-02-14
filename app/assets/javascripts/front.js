var myLocator;
var mySportsUI;
// This is where all the page initialisation happens.
$(document).ready(function () {
    // first locate
    //mySportsUI = Object.create(sports_ui);
    mySportsUI = new sports_ui;
    myLocator = new locator;
    myLocator.sports_ui = mySportsUI; 
    if (navigator.geolocation) { 
      navigator.geolocation.getCurrentPosition(
      function(position) {
        latitude = position.coords.latitude;
        longitude = position.coords.longitude;
        myLocator.codeLatLng(latitude, longitude); // this should not call myLocator, it should be 'this' but the problem is this 'successFunction' is a CallBack and doesn't seem to send the whole object
      },
      function() {
        $('#location_guess').html("We can't find you. We'll put you in New York");
      }
    );
    }


    // then fill out left menu 

    // then fill out center menu
    });

var sports_ui = function() {
  this.leagues_jsons = {} 
};

sports_ui.prototype.updateEvents = function(country) {
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
      $("#list1 ").append('<li class="ui-li ui-li-static ui-btn-up-c league_id_'+e.league_id+'" timestamp="'+start_date_utc.getTime()+'"><p class="ui-li-aside ui-li-desc"><strong>'+e.time_in_words+'</strong> <sup>'+start_date_local+'</sup></p>'+e.league+' - '+e.teams[0].name + ' vs ' + e.teams[1].name +' </li>')
      //            $('#events').append(j+"  :"+e.league.name + " - ");  
      //           $('#events').append("  >>"+e.teams[0].name + " vs " + e.teams[1].name );  
      //          $('#events').append(" start: "+e.start_date+"<br />");  
      }
      }
      //}
      //$.mobile.loading('hide');
  }); 
};
sports_ui.prototype.displayEventsForLeague =  function(events) {
  // cache it if it hasn't been cahsed before
  if (events.length > 0) {
    if (!this.leagues_jsons.hasOwnProperty("L"+events[0].league_id)) {
      this.leagues_jsons["L"+events[0].league_id] = events;
    }
  }

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

      var new_event;
      new_event = '<li class="ui-li ui-li-static ui-btn-up-c league_id_'+e.league_id+'" timestamp="'+start_date_utc.getTime()+'"><p class="ui-li-aside ui-li-desc"><strong>'+e.time_in_words+'</strong> <sup>'+start_date_local+'</sup></p>'+e.league+' - '+e.teams[0].name + '  vs ' + e.teams[1].name +' </li>';

      if ($('#list1 li').length ==0) {
        //$(new_event).hide().append($("#list1")).effect("highlight", {}, 1500);;
        $('#list1').append(new_event).hide().effect("highlight", {},1500);
      } else {
      for (var j = $('#list1 li').length-1;j>=0;j--) {
        var list_item = $('#list1 li')[j];
        if (parseInt(list_item.getAttribute("timestamp")) <= timestamp) {
          //new_event = '<li class="ui-li ui-li-static ui-btn-up-c league_id_'+e.league_id+'"><p class="ui-li-aside ui-li-desc"><strong>'+e.time_in_words+'</strong> <sup>'+start_date_local+'</sup></p>'+e.league+' - '+e.teams[0].name + '  vs ' + e.teams[1].name +' </li>';
    
            $(new_event).hide().insertAfter($("#list1 li:nth-child("+(j+1)+")")).effect("highlight", {}, 1500);;

          //$('<li class="ui-li ui-li-static ui-btn-up-c league_id_'+league_id+'"><p class="ui-li-aside ui-li-desc"><strong>'+e.time_in_words+'</strong> <sup>'+start_date_local+'</sup></p>'+e.league+' - '+e.teams[0].name + '  vs ' + e.teams[1].name +' </li>').hide().insertAfter($("#list1 li:nth-child("+j+")")).effect("highlight", {}, 1500);;
          //$("#list1 li:nth-child("+j+")").insertAfter('<li class="ui-li ui-li-static ui-btn-up-c"><p class="ui-li-aside ui-li-desc"><strong>'+e.time_in_words+'</strong> <sup>'+start_date_local+'</sup></p>'+e.league+' - '+e.teams[0].name + ' !!!!vs ' + e.teams[1].name +' </li>')
          //$("#list1 li")[j].insertBefore('<li class="ui-li ui-li-static ui-btn-up-c"><p class="ui-li-aside ui-li-desc"><strong>'+e.time_in_words+'</strong> <sup>'+start_date_local+'</sup></p>'+e.league+' - '+e.teams[0].name + ' !!!!vs ' + e.teams[1].name +' </li>')
          break;
        }
      }
    }
    }
  }
}

sports_ui.prototype.getEvents = function(cb,league_id) {
      var me = this;
  if (!cb.checked) { // hide all events for this league
    $('.league_id_'+league_id).fadeOut(1000);
    setTimeout(function(){$('.league_id_'+league_id).remove()}, 1000);
  } else {
    if (this.leagues_jsons.hasOwnProperty("L"+league_id)) {
      //$('.league_id_'+league_id).show().effect("highlight",{},1500);
      this.displayEventsForLeague(this.leagues_jsons["L"+league_id]);
    } else {
      $.getJSON( '/leagues/events/'+league_id+'.json',
          { },
          function (events) {
            me.displayEventsForLeague(events)
          }
      );
    }
  }
};

sports_ui.prototype.updateTree = function(country) {
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
          $('#main_sports_list').append('<li>'+leagues[i].name+'<input type=checkbox align=right onclick="mySportsUI.getEvents(this, '+leagues[i].id+')"></li>');
          break;
        case 2:
          theres_more = true;
          $('#main_sports_list').append('<li class="league_hidden tree_league_id_'+leagues[i].sport_id+'">'+leagues[i].name+'<input type=checkbox id='+leagues[i].sport_id+' onclick="mySportsUI.getEvents(this,'+leagues[i].id+')" align=right></li>');
          break;
        default:
          $('#main_sports_list').append('<li>'+leagues[i].name+'<input type=checkbox onclick="mySportsUI.getEvents(this, '+leagues[i].id+')" checked align=right></li>');
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
}; 

sports_ui.prototype.localize = function(t)
{
  var d=new Date(t+" UTC");
  document.write(d.toString());
}
