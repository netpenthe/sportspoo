timezoneJS.timezone.zoneFileBasePath = '/assets/tz';
timezoneJS.timezone.defaultZoneFile = ['asia', 'australasia', 'backward', 'europe','northamerica', 'southamerica'];
timezoneJS.timezone.init();
var myLocator;
//var mySportsUI;
// This is where all the page initialisation happens.
$(document).ready(function () {
    // first locate
    //mySportsUI = Object.create(sports_ui);
 //   mySportsUI = new sports_ui;
    //mySportsUI.displayEventsForLeague(mySportsUI.my_events,"my_events");
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

     $('#search_wrapper').mouseover(function() {
  //     $('#results_wrapper').fadeIn();
     });
     $('#results_wrapper').mouseleave(function() {
       $('#results_wrapper').fadeOut();
       $('#show_results').show(); 
     });
    });

var sports_ui = function() {
  this.leagues_jsons = {},
  this.my_events = {}
  this.league_ids = [];
  this.my_teams = [];
};

sports_ui.prototype.change_time_zone_select = function(tz) {
  var s = tz.options[tz.selectedIndex];
  //var offset = tz.options[tz.selectedIndex].text.replace(/\(GMT(.*)\) .*$/,"$1");
  //this.change_time_zone(offset);
  var me = this;
  $.getJSON( '/front/get_tz_offset/'+s.value+'.txt?',
      { },
      function(txt) {
        me.change_time_zone(txt+"");
  }); 
}

  // NOTE: offset is 10.5 NOT 1030
sports_ui.prototype.change_time_zone = function(offset) {
  var ts;
  // for each events
  var me = this;
  $( "#list1 li" ).each(function( index ) {
    ts = $(this).attr("timestamp")*1
    var nd = me.convertTZ2(ts,offset); 
    nd = moment(nd).format('ddd h:mma');
    $(this).children('.ui-li-desc').text(nd); 
  });
    // get timestamp
    // update time
}
/* updateInitialEvents() is only called the first time a page is loaded, note it processes 'my_events' at the end */
sports_ui.prototype.updateInitialEvents = function(country) {
  var now = new Date();
  var me = this;
  $.getJSON( '/country/events/'+country+'.json?'+now.getTime(),
      { },
      function(events) {
        var start_date_utc, start_date_local;
        for (j=0;j<events.length;j++) {
          e = events[j];
          me.league_ids.push(parseInt(e.league_id));
          if (e.teams.length==2) {
            start_date_utc = new Date(e.start_date);
            //start_date_local = start_date_utc.toString('ddd hh:mmtt'); 
            //start_date_local = moment(start_date_utc).format('ddd h:mma');
            start_date_local = "";
            $("#list1 ").append('<li class="ui-li ui-li-static ui-btn-up-c league_event league_id_'+e.league_id+' T'+e.teams[0].id+' T'+e.teams[1].id+'" league_id="'+e.league_id+'" event_id="'+e.id+'" timestamp="'+start_date_utc.getTime()+'"><p class="ui-li-aside ui-li-desc"><strong>'+e.time_in_words+'</strong> <sup>'+start_date_local+'</sup></p>'+e.league+' - '+e.teams[0].name + ' vs ' + e.teams[1].name +' </li>')
          }
        }
        //me.removeEvents(me.my_events);
        me.displayEventsForLeague(me.my_events,"my_events");
        me.change_time_zone(myLocator.defaultOffset);
  }); 
};
sports_ui.prototype.removeEvents =  function(events) {
  for (var i = 0; i < events.length; i++) {
    $('li[event_id="'+events[i].id+'"]').remove();
  }
}

sports_ui.prototype.displayEventsForLeague =  function(events,custom_class) {
  this.removeEvents(events);
  // cache it if it hasn't been cahsed before
  if (events.length > 0 && custom_class !== "my_events") {
    if (!this.leagues_jsons.hasOwnProperty("L"+events[0].league_id)) {
      this.leagues_jsons["L"+events[0].league_id] = events;
    }
  }

  var start_date_utc, start_date_local, timestamp;
  for (var i=0;i<events.length;i++) {
    e = events[i];
    if (e.teams.length==2) {
      start_date_utc = new Date(e.start_date);
      //start_date_local = start_date_utc.toString('ddd hh:mmtt'); 
      start_date_local = moment(start_date_utc).format('ddd h:mma');
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
      new_event = '<li class="ui-li ui-li-static ui-btn-up-c league_id_'+e.league_id+' '+custom_class+' T'+e.teams[0].id+' T'+e.teams[1].id+'" league_id="'+e.league_id+'" event_id='+e.id+' timestamp="'+start_date_utc.getTime()+'"><p class="ui-li-aside ui-li-desc"><strong>'+e.time_in_words+'</strong> <sup>'+start_date_local+'</sup></p>'+e.league+' - '+e.teams[0].name + '  vs ' + e.teams[1].name +' </li>';

      if ($('#list1 li').length ==0) {
        //$(new_event).hide().append($("#list1")).effect("highlight", {}, 1500);;
        $('#list1').append(new_event).hide().effect("highlight", {},1500);
      } else {
      for (var j = $('#list1 li').length-1;j>=0;j--) {
        var list_item = $('#list1 li')[j];
            j 
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
  this.highlightMyEvents();
}

sports_ui.prototype.getEvents = function(cb,league_id) {
  var me = this;
  if (this.league_ids.indexOf(league_id) <= -1) {
    this.league_ids.push(parseInt(league_id));
  }

  if (!cb.checked) { // hide all events for this league
    $('.league_id_'+league_id).not('.my_events').fadeOut(1000);
    //setTimeout(function(){$('.league_id_'+league_id+':not(.my_events)').remove()}, 1000);
    setTimeout(function(){$('.league_id_'+league_id).not('.my_events').remove()}, 1000);
    //setTimeout(function(){$('.league_id_'+league_id).remove()}, 1000);
  } else {
    if (this.leagues_jsons.hasOwnProperty("L"+league_id)) {
      //$('.league_id_'+league_id).show().effect("highlight",{},1500);
      this.displayEventsForLeague(this.leagues_jsons["L"+league_id]);
    } else {
      $.getJSON( '/leagues/events/'+league_id+'.json',
          { },
          function (events) {
            me.displayEventsForLeague(events);
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

sports_ui.prototype.highlightMyEvents = function() {
  for (var i=0; i<this.my_teams.length; i++) {
    if ($('#my_teams_T'+this.my_teams[i]).attr("checked")) {
      $(".T"+this.my_teams[i]).addClass("my_events");  
    }
  }
}
// The user clicked a "My Teams" checkbox
sports_ui.prototype.clickMyTeam = function(team) {
  var me = this;
  team_id = team.getAttribute("team_id");
  if (team.checked) {
    var now = new Date();
    // first highlight any existing MY_TEAMS events on the screen
    this.highlightMyEvents();
    $.getJSON("/front/user_events_by_team/"+team_id+"/30.json?"+now.toString(),
        { },
        function(events) {
          me.displayEventsForLeague(events,"my_events");
    }); 
  } else {
    $('.T'+team_id).each(function() {
      $(this).removeClass("my_events");
      if (me.league_ids.indexOf(parseInt($(this).attr("league_id"))) <= -1)
      {
        $(this).remove();
      }
    });
  }
}

sports_ui.prototype.addMyTeam = function(team_name,team_id) {
  if ($('#my_teams_T'+team_id).length === 0) {
    $('#my_teams').append("<li>"+team_name+'<input id="my_teams_T'+team_id+'" type="checkbox" align="right" style="float:right" onclick="mySportsUI.clickMyTeam(this)" team_id="'+team_id+'" checked="checked"></li>');
    this.my_teams.push(team_id);
  } else {
    $('#my_teams_T'+team_id).parent().effect("highlight", {},1500);
  }
  
  this.clickMyTeam(document.getElementById('my_teams_T'+team_id)); 
  $('#my_teams_label').show();
}

sports_ui.prototype.convertTZ = function (d, offset) {
  // offset is something like Adelaide: +1030, Offset is: -630 (10 hours * 60 minutes = 600 minutes + 30 minutes)
  var seconds = d.getTime(); // get in milliseconds
  alert(moment().format("ddd h:mma"));
}

// offset is 10.5 hours or -2 hours etc
sports_ui.prototype.convertTZ2 = function (timestamp,offset) {
    var d = new Date(timestamp);

    //Deal with dates in milliseconds for most accuracy
    var utc = d.getTime() + (d.getTimezoneOffset() * 60000);
    var newDateWithOffset = new Date(utc + (3600000*offset));

    //This will return the date with the locale format (string), or just return newDateWithOffset
    //and go from there.
    return newDateWithOffset.toLocaleString();
}

sports_ui.prototype.set_tz_selector = function (city,offset_no_dst) {
  $('#tz_selector').val(city);
  if ($('#tz_selector').val() == city) {
    // city was succesffully selected
    return;
  }
  // do a search for it
  $.each($('#tz_selector option:contains('+offset_no_dst+')'), function(i,val) {
    // bugger it, for now just return the first one :)
    $('#tz_selector').val($(this).val);
    return;
  });


}


