class FrontController < ApplicationController

  def index
    if request.location.blank?
      @country = 'Australia'
    else
      @country = request.location.country == 'Reserved' ? 'Australia' : request.location.country
    end

    if (session[:leagues].nil?)
      session[:leagues] = []
    end
    if (session[:teams].nil?) 
      session[:leagues] = []
    end 
    if (session[:tz].nil?) 
      session[:tz] = ""
    end 

    @leagues = session[:leagues]
    @teams = session[:teams]

    # When a person first hits the "join" or "facebook" or "twitter" buttons
    # we save their current settings (teams/leagues) into a session
    # If they get back here it means they've signed up.. if it is their first signup
    # save their settings to UserPreferencers
    if current_user && current_user.sign_in_count == 1
      teams = session[:teams].split(",")
      leagues = session[:leagues].split(",")
      current_user.tz = session[:tz]
      current_user.addInitialTeams(teams)
      current_user.addInitialLeagues(leagues)
      current_user.sign_in_count = 2
      current_user.save!
    end

    if current_user 
      #@my_leagues_json = current_user.my_leagues.to_json
      #@my_teams_json = current_user.my_teams.to_json(:include => [:sport], :methods=>[:display_name, :countdown, :league_name])
      #@my_events_json = User.upcoming_events(current_user,50(current_user,50)).to_json
      @tz = current_user.tz
    else  
      @c_nt = Country.find_by_name @country

      @country_events = @c_nt.upcoming_events.to_json(
                    :include => [:event_teams,:teams], 
                    :methods=>[:tag_list,:display_name,:countdown, :league_name, :league_label_colour,:live,:betfair_link])

      @country_leagues  = @c_nt.leagues.to_json(:params=>{:country_id => @c_nt.id})

      if request.location.blank?
        city = 'Sydney'
      else
        city = request.location.city.blank? ? "" : request.location.city
      end

      @city = city

      if (!city.blank?) 
        x = Citytimezones.find(:first, :conditions=>["city like ?",city+'%'])
        @tz = x.present? ? x.tz_dropdown : ""
      else 
        @tz = ""
      end
    end
    if params[:login] == "failed"
      @login = "failed"
    end

   
    respond_to do |format|
      if is_mobile_device? 
        format.html { render :layout=>"mobile" and return } 
      else 
        format.html { render :layout=>"application" and return } 
      end 
    end
  end
  
  def moar_events
    page = params[:page]
    offset = page.to_i * Constants::NUM_EVENTS_TO_SHOW
    if current_user
      @events = Event.upcoming_events_for_user(current_user,Constants::NUM_EVENTS_TO_SHOW,offset)
    else  
      @events = (Country.find_by_name "Australia").upcoming_events_moar.slice(offset,Constants::NUM_EVENTS_TO_SHOW)
    end
    respond_to do |format|
        format.json { render json: @events, :include => [:teams], :methods=>[:tag_list,:display_name,:countdown, :league_name, :league_label_colour,:live, :betfair_link]}
    end
  end


  def list
    #query for leagues
    # select events.id,start_date from events join leagues on leagues.id = events.league_id
    #  join user_preferences on (user_preferences.preference_id = league_id and preference_type='League')
    #  where user_id=1;
    user = current_user unless current_user.blank?
    user = User.find_by_username params[:username] if user.blank?

    @user = user

    Time.zone = user.tz unless user.tz.blank?
  
    @team_events = Array.new
    @league_events = Array.new
    @sport_events = Array.new
   
    @league_events = Event.find_by_sql ["select events.* from events join leagues on leagues.id = events.league_id
      join user_preferences on (user_preferences.preference_id = league_id and preference_type='League')
      where user_id=? and start_date > ? and start_date < ?", user.id,Time.now,Time.now+21.days]
    
    @team_events = Event.find_by_sql ["select events.* from events 
      join event_teams on events.id = event_teams.event_id
      inner join user_preferences on (user_preferences.preference_id=team_id and preference_type='Team')
      where user_id=? and start_date > ? and start_date < ?", user.id,Time.now,Time.now+21.days]
    
    @events = @league_events + @sport_events + @team_events

    @events.sort!{|x,y| x.start_date <=> y.start_date}

    @events.uniq!{|e| e.id}

    puts @events.count
    
     respond_to do |format|
        format.html #{ render :layout=>"mobile"} 
        #format.json { render json: @events, :include => [:teams], :methods=>[:tag_list,:display_name,:countdown, :league_name, :league_label_colour,:live,:betfair_link]}
     end
    
  end


  def chat
    @user = User.find_by_username params[:username]
  end


  
  def list_username    
    @user = User.find_by_username params[:username]
    @events = Event.where(["(league_id = 18 or league_id=6 or league_id=38 or league_id=2) 
                             and start_date > ? and start_date < ?", Time.now,Time.now+3.days]).order("start_date ASC")
  end

  def events
    @events = Event.where(["start_date > ? and start_date < ?", Time.now,Time.now+3.days]).order("start_date ASC").limit(50)
  end

  def user_events
     num_events = params[:num_events] || Constants::NUM_EVENTS_TO_SHOW
     if current_user
       events = Event.upcoming_events_for_user(current_user,num_events,0)
      else 
        events = []
      end 
     respond_to do |format|
        #format.json { render json: @country.upcoming_events, :include => [:teams], :methods=>[:display_name,:countdown, :league_name]}
        format.json { render json: events, :include => [:teams], :methods=>[:tag_list,:display_name,:countdown, :league_name, :league_label_colour,:live,:betfair_link]}
     end
  end

  def user_events_by_team
     team_id = params[:team_id].to_i
     num_events = params[:num_events] || 10
     if current_user && team_id
       events = Event.upcoming_events_for_user_by_team(current_user,team_id,num_events)
       UserPreference.find_or_create_by_user_id_and_preference_type_and_preference_id(current_user.id,"Team",team_id)
      else 
       events = Event.upcoming_events_by_team(team_id,num_events)
      end 
     respond_to do |format|
        #format.json { render json: @country.upcoming_events, :include => [:teams], :methods=>[:display_name,:countdown, :league_name]}
        format.json { render json: events, :include => [:teams],  :methods=>[:tag_list,:display_name,:countdown, :league_name, :league_label_colour,:live,:betfair_link] }
     end
  end

  def search
    s=params[:search]
    #teams = Team.find(:all,:limit=>10,:conditions=>["(name like ?)","%#{s}%"])
    teams = Team.search_name_and_tags(s,15)
    leagues = League.search_name(s,15)
    events = Event.find_by_team(teams) + Event.find_by_league(leagues)
    respond_to do |format|
      #format.json { render json: teams, :include => [:sport], :methods=>[:display_name, :countdown, :league_name]}
      format.json { render :json =>{:events=>events.to_json(:include => [:teams],  :methods=>[:tag_list,:display_name,:countdown, :league_name, 
           :league_label_colour,:live,:betfair_link], :include => [:teams,:sport],  :methods=>[:tag_list,:display_name,:countdown, :league_name, :league_label_colour,:live]),
            :teams => teams.to_json(:include => [:sport], :methods=>[:display_name, :countdown, :league_name]), :leagues => leagues.to_json}}
    end
  end

  def get_tz_offset
    tz = ActiveSupport::TimeZone::MAPPING[params[:tz]]
    Time.zone=TZInfo::Timezone.get(tz)
    offset = Time.zone.now.utc_offset/60.0/60.0
    respond_to do |format|
      format.text {render :text => offset}
    end
  end

  def save_session
    session[:leagues] = params[:leagues]
    session[:teams]   = params[:teams]
    session[:tz]   = params[:tz]
    respond_to do |format|
      format.text {render :text => "ok"}
    end
  end

end
