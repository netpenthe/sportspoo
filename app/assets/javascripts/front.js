
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
    if (typeof mySportsUI.my_leagues !== "undefined" && mySportsUI.my_leagues.length > 0) {
      mySportsUI.updateTreeJSON(mySportsUI.my_leagues);
      mySportsUI.updateInitialEventsJSON(mySportsUI.my_events);
    } 
    {
      if (navigator.geolocation) { 
      navigator.geolocation.getCurrentPosition(
        function(position) {
        latitude = position.coords.latitude;
        longitude = position.coords.longitude;
        myLocator.codeLatLng(latitude, longitude); // this should not call myLocator, it should be 'this' but the problem is this 'successFunction' is a CallBack and doesn't seem to send the whole object
        },
        function(err) {
        myLocator.country = sports_geo_country; // this reads from the IP address, this is a variable set by Rails in _main.html.erb
        myLocator.locationFound();
        },{timeout:48000} // 3 seconds
        );
      }
    }
    // then fill out left menu 
    // then fill out center menu

    $('#results_wrapper').mouseleave(function() {
        $('#results_wrapper').fadeOut();
        $('#show_results').show(); 
        });
    $('.save_preferences').click(mySportsUI.save_current_preferences);
});

var sports_ui = function() {
  this.leagues_jsons = {},
    this.my_events = {}
  this.league_ids = [];
  this.my_teams = [];
};

sports_ui.prototype.save_current_preferences = function() {
  alert("Saving preferences");
  return true;
}

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
sports_ui.prototype.change_time_zone = function(offset,highlight) {
  var ts;
  var highlight = typeof highlight !== 'undefined' ? highlight : true;
  // for each events
  var me = this;
  $( "#list1 li" ).each(function( index ) {
    ts = $(this).attr("timestamp")*1
    var nd = me.convertTZ2(ts,offset); 
    //nd = nd + " +0000"; //this ensures that moment knows this date was in GMT
    //nd = moment(nd).format('ddd h:mma');

    //alert(nd);
    nd = moment(nd,"DD/MM/YYYY HH:mm:ss a").format('ddd h:mma');
    //nd = moment(nd).format('ddd h:mma');
    $(this).children('.ui-li-desc').children('sup').text(nd); 
    if (highlight) { 
      $(this).children('.ui-li-desc').children('sup').effect("highlight", {},500); 
    }
  });
    // get timestamp
    // update time
}

sports_ui.prototype.updateInitialEventsJSON = function(events) {
  var start_date_utc, start_date_local;
  var teams_class = "";
  var display_name = "";
  var time_in_words ="";
  for (j=0;j<events.length;j++) {
    e = events[j];
    this.league_ids.push(parseInt(e.league_id));
    if (e.teams.length==2) {
      teams_class=' T'+e.teams[0].id+' T'+e.teams[1].id;
      display_name = e.teams[0].name + ' vs ' + e.teams[1].name ;
    } else {
      display_name = e.name;
    }

    if (e.runnning) {
      time_in_words = "running!";
    } else {
      time_in_words = e.time_in_words;
    }

    start_date_utc = new Date(e.start_date);
    //start_date_local = start_date_utc.toString('ddd hh:mmtt'); 
    //start_date_local = moment(start_date_utc).format('ddd h:mma');
    start_date_local = "";
    league_label_colour = e.league_label_colour;

    // show live event label
    live_event_str = "  ";
    if(e.live){
      live_event_str = " <span class='label' style='background-color:green; font-size:10px;'>LIVE</span> ";
    }

    //show event tags/label
    var tag_str = "";
    var t;
    for (t = 0; t < e.tag_list.length; t++) {
      tag_str = tag_str + " <span class='label' style='background-color:#0099cc; font-size:10px;'> " + e.tag_list[t] + "</span> ";
    }


    if (e.live){
      time_in_words = " ";
    }

    $("#list1 ").append('<li class="ui-li ui-li-static ui-btn-up-c league_event league_id_'+e.league_id+teams_class+'" league_id="'+e.league_id+'" event_id="'+e.id+'" timestamp="'+start_date_utc.getTime()+'"><p class="ui-li-aside ui-li-desc"><strong>'+time_in_words+'</strong> <sup >'+start_date_local+'</sup></p>'+display_name+ '  <span class="label" style="background-color:'+ league_label_colour+'; font-size:10px;" data-name="activesupport">'+e.league+'</span> '  + tag_str  + live_event_str + ' </li>')
  }
  //me.removeEvents(me.my_events);
  this.displayEventsForLeague(this.my_events,"my_events");
  this.change_time_zone(myLocator.defaultOffset, false);
}


/* updateInitialEvents() is only called the first time a page is loaded, note it processes 'my_events' at the end */
sports_ui.prototype.updateInitialEvents = function(country) {
  var now = new Date();
  var me = this;
  if (typeof this.my_events == 'undefined' || typeof this.my_events.length == 'undefined' || this.my_events.length == 0) {
    $.getJSON( '/country/events/'+country+'.json?'+now.getTime(),
        { },
        function(events) {
        me.updateInitialEventsJSON(events);
        }
        ); 
  } else {
    this.updateInitialEventsJSON(this.my_events);
  }
}

sports_ui.prototype.removeEvents =  function(events) {
  if (events !== 'undefined' && events !== null) { 
    for (var i = 0; i < events.length; i++) {
      $('li[event_id="'+events[i].id+'"]').remove();
    }
  }
}

sports_ui.prototype.displayEventsForLeague =  function(events,custom_class) {
  if (events === null || events.length == 0) {
    return;
  }
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
      var teams_class = "";
      var display_name = "";
      if (e.teams.length==2) {
        teams_class=' T'+e.teams[0].id+' T'+e.teams[1].id;
        display_name = e.teams[0].name + ' vs ' + e.teams[1].name ;
      } else {
        display_name = e.name;
      }
 
      start_date_utc = new Date(e.start_date);
      //start_date_local = start_date_utc.toString('ddd hh:mmtt'); 
      start_date_local = moment(start_date_utc).format('ddd h:mma');
      timestamp = start_date_utc.getTime();

      var new_event;
      new_event = '<li class="ui-li ui-li-static ui-btn-up-c league_id_'+e.league_id+' '+custom_class+teams_class+'" league_id="'+e.league_id+'" event_id='+e.id+' timestamp="'+start_date_utc.getTime()+'"><p class="ui-li-aside ui-li-desc"><strong>'+e.time_in_words+'</strong> <sup>'+start_date_local+'</sup></p>'+display_name +'  <span class="label labelstyle-FC9300" data-name="activesupport">'+e.league+'</span> </li>';

      if ($('#list1 li').length ==0) {
        $('#list1').append(new_event).hide().effect("highlight", {},1500);
      } else {
        for (var j = $('#list1 li').length-1;j>=0;j--) {
          var list_item = $('#list1 li')[j];
            if (parseInt(list_item.getAttribute("timestamp")) <= timestamp) {
              $(new_event).hide().insertAfter($("#list1 li:nth-child("+(j+1)+")")).effect("highlight", {}, 1500);;
              break;
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
    $.getJSON( '/user_preference/remove_league/'+league_id+'.json', { }, function() {});
    
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


sports_ui.prototype.updateTreeJSON = function(leagues) {
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
        $('#main_sports_list').append('<li>'+leagues[i].name+'<input type=checkbox align=right  style="float:right" onclick="mySportsUI.getEvents(this, '+leagues[i].id+')"></li>');
        break;
      case 2:
        theres_more = true;
        $('#main_sports_list').append('<li class="league_hidden tree_league_id_'+leagues[i].sport_id+'">'+leagues[i].name+'<input type=checkbox id='+leagues[i].sport_id+' onclick="mySportsUI.getEvents(this,'+leagues[i].id+')" align=right style="float:right"></li>');
        break;
      default:
        $('#main_sports_list').append('<li>'+leagues[i].name+'<input type=checkbox onclick="mySportsUI.getEvents(this, '+leagues[i].id+')" checked align=right style="float:right"></li>');
        break;
    }

    //$("#list1 ").append('<li class="ui-li ui-li-static ui-btn-up-c"><p class="ui-li-aside ui-li-desc"><strong>'+e.time_in_words+'</strong></p>'+e.league+' - '+e.teams[0].name + ' vs ' + e.teams[1].name +' </li>')
    //            $('#events').append(j+"  :"+e.league.name + " - ");  
    //           $('#events').append("  >>"+e.teams[0].name + " vs " + e.teams[1].name );  
    //          $('#events').append(" start: "+e.start_date+"<br />");  
  }
  $('#main_sports_list').append('</ul>');
  //}
} 

sports_ui.prototype.updateTree = function(country) {
  var me = this;
  if (typeof this.my_leagues == 'undefined' || this.my_leagues.length == 0) {
    $.getJSON( '/country/leagues/'+country+'.json',
        { },
        function(leagues) {
          me.updateTreeJSON(leagues);
        });
  } else {
    this.updateTreeJSON(this.my_leagues);
  }
}

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
    $.getJSON( '/user_preference/remove_team/'+team_id+'.json', { }, function() {}); //remove from user preferences
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
  offset_no_dst=offset_no_dst.replace(/(GMT[-|+])([0-9]):/,"$10$2:")
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


