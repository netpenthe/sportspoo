class FrontController < ApplicationController

  def index
    if (session[:leagues].nil?)
      session[:leagues] = []
      session[:teams] = []
      session[:leagues] = []
    end
    @leagues = session[:leagues]
    @teams = session[:teams]

    if current_user
      #@my_leagues_json = current_user.my_leagues.to_json
      #@my_teams_json = current_user.my_teams.to_json(:include => [:sport], :methods=>[:display_name, :countdown, :league_name])
      #@my_events_json = User.upcoming_events(current_user,50(current_user,50)).to_json
    end
  end

  def list
    #query for leagues
    # select events.id,start_date from events join leagues on leagues.id = events.league_id
    #  join user_preferences on (user_preferences.preference_id = league_id and preference_type='League')
    #  where user_id=1;
    user = current_user unless current_user.blank?
    user = User.find_by_username params[:username] if user.blank?
  
    @team_events = Array.new
    @league_events = Array.new
    @sport_events = Array.new
   
    @league_events = Event.find_by_sql ["select events.* from events join leagues on leagues.id = events.league_id
      join user_preferences on (user_preferences.preference_id = league_id and preference_type='League')
      where user_id=? and start_date > ? and start_date < ?", user.id,Time.now,Time.now+14.days]
    
    @team_events = Event.find_by_sql ["select events.* from events 
      join event_teams on events.id = event_teams.event_id
      inner join user_preferences on (user_preferences.preference_id=team_id and preference_type='Team')
      where user_id=? and start_date > ? and start_date < ?", user.id,Time.now,Time.now+14.days]
    
    @events = @league_events + @sport_events + @team_events

    @events.sort!{|x,y| x.start_date <=> y.start_date}

     respond_to do |format|
        format.html { render :layout=>"mobile"} 
        format.json { render json: @events, :include => [:teams], :methods=>[:tag_list,:display_name,:countdown, :league_name, :league_label_colour,:live]}
     end
    
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
     num_events = params[:num_events] || 10
     if current_user
       events = Event.upcoming_events_for_user(current_user,num_events)
      else 
        events = []
      end 
     respond_to do |format|
        #format.json { render json: @country.upcoming_events, :include => [:teams], :methods=>[:display_name,:countdown, :league_name]}
        format.json { render json: events, :include => [:teams], :methods=>[:tag_list,:display_name,:countdown, :league_name, :league_label_colour,:live]}
     end
  end

  def user_events_by_team
     team_id = params[:team_id].to_i
     num_events = params[:num_events] || 10
     if current_user && team_id
       events = Event.upcoming_events_for_user_by_team(current_user,team_id,num_events)
       UserPreference.find_or_create_by_user_id_and_preference_type_and_preference_id(current_user.id,"Team",team_id)
      else 
        events = []
      end 
     respond_to do |format|
        #format.json { render json: @country.upcoming_events, :include => [:teams], :methods=>[:display_name,:countdown, :league_name]}
        format.json { render json: events, :include => [:teams],  :methods=>[:tag_list,:display_name,:countdown, :league_name, :league_label_colour,:live] }
     end
  end

  def search
    s=params[:search]
    #teams = Team.find(:all,:limit=>10,:conditions=>["(name like ?)","%#{s}%"])
    teams = Team.search_name_and_tags(s,15)
    leagues = League.search_name(s,15)
    respond_to do |format|
      #format.json { render json: teams, :include => [:sport], :methods=>[:display_name, :countdown, :league_name]}
      format.json { render :json =>{:teams => teams.to_json(:include => [:sport], :methods=>[:display_name, :countdown, :league_name]), :leagues => leagues.to_json}}
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
    #session[:leagues] =
    #session[:teams] =
  end

end
