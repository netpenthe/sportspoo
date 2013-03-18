class CountriesController < ApplicationController

  #caches_page :leagues
  #caches_page :events


  def leagues 
    #if current_user # show only user's leagues
      #@leagues = current_user.my_leagues 
    #else
      @country = Country.find_by_name params[:country]
    #end
    respond_to do |format|
      format.json { render json: @country.leagues, :params=>{:country_id => @country.id}}
    end
  end


  def events
    #if current_user # show only user's events
      #@events = Event.find(:all, :limit=>20)
    #else 
      @events = (Country.find_by_name params[:country]).upcoming_events
    #end 
     respond_to do |format|
        format.json { render json: @events, :include => [:teams], :methods=>[:tag_list,:display_name,:countdown, :league_name, :league_label_colour]}
     end
  end

end
