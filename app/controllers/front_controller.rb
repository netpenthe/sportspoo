class FrontController < ApplicationController

  def index
  end

  def list
    #query for leagues
    # select events.id,start_date from events join leagues on leagues.id = events.league_id
    #  join user_preferences on (user_preferences.preference_id = league_id and preference_type='League')
    #  where user_id=1;
    
    @events = Event.where(["(league_id = 18 or league_id=6 or league_id=38 or league_id=2) 
                             and start_date > ? and start_date < ?", Time.now,Time.now+3.days]).order("start_date ASC")
  end
  
  def list_username    
    @user = User.find_by_username params[:username]
    @events = Event.where(["(league_id = 18 or league_id=6 or league_id=38 or league_id=2) 
                             and start_date > ? and start_date < ?", Time.now,Time.now+3.days]).order("start_date ASC")
  end

end
