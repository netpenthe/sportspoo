class CountriesController < ApplicationController

  caches_page :leagues
  caches_page :events


  def leagues 
     @country = Country.find_by_name params[:country]

     respond_to do |format|
        format.json { render json: @country.leagues, :params=>{:country_id => @country.id}}
     end
  end


  def events
     @country = Country.find_by_name params[:country]

     respond_to do |format|
        format.json { render json: @country.upcoming_events, :include => [:teams], :methods=>[:display_name,:countdown, :league_name]}
     end
  end

end
