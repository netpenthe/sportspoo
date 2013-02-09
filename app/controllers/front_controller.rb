class FrontController < ApplicationController

  def index
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
      where user_id=? and start_date > ? and start_date < ?", user.id,Time.now,Time.now+7.days]

    @sport_events = Event.find_by_sql ["select events.* from events join sports on sports.id = events.sport_id
      join user_preferences on (user_preferences.preference_id = sport_id and preference_type='Sport')
      where user_id=? and start_date > ? and start_date < ?", user.id,Time.now,Time.now+7.days]

    #@team_events = Event.find_by_sql ["select events.* from events join teams on (teams.id = events.home_team_id or teams.id = events.away_team_id)
    #  join user_preferences on ((user_preferences.preference_id = home_team_id and preference_type='Team') or (user_preferences.preference_id = away_team_id and preference_type='Team'))
    #  where user_id=? and start_date > ? and start_date < ?", user.id,Time.now,Time.now+7.days]
    
    @events = @league_events + @sport_events + @team_events

    @events.sort!{|x,y| x.start_date <=> y.start_date}
  end
  
  def list_username    
    @user = User.find_by_username params[:username]
    @events = Event.where(["(league_id = 18 or league_id=6 or league_id=38 or league_id=2) 
                             and start_date > ? and start_date < ?", Time.now,Time.now+3.days]).order("start_date ASC")
  end

  def events
    @events = Event.where(["start_date > ? and start_date < ?", Time.now,Time.now+3.days]).order("start_date ASC").limit(50)
  end


end
