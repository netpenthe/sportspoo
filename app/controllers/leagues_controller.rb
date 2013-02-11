class LeaguesController < ApplicationController

  def all

     respond_to do |format|
      #format.json { render json: @country.upcoming_events}
      #format.json { render json: League.all, :include => [:sports]}
      format.json { render json: League.all} 
     end
  end

  def country
     country = Country.find_by_name(params[:country])
     respond_to do |format|
      #format.json { render json: @country.upcoming_events}
      #format.json { render json: League.all, :include => [:sports]}
      format.json { render json: country.leagues} 
     end
  end
  def events
    #@events = Event.find_all_by_league_id(params[:league_id])
    #@events = Event.find(:all, :conditions=>"league_id = #{params[:league_id]} and )
    @events = Event.upcoming_events(params[:league_id])

    respond_to do |format|
      format.json { render json: @events, :include => [:teams]}
    end
  end

end
