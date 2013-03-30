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
    if (current_user and params[:league_id])
      if League.find(params[:league_id]).present?
         UserPreference.find_or_create_by_user_id_and_preference_type_and_preference_id(current_user.id,"League",params[:league_id])
      end
    end

    respond_to do |format|
      format.json { render json: @events, :include => [:teams], :methods=>[:tag_list,:display_name,:countdown, :league_name, :league_label_colour,:live]}
    end
  end

end
