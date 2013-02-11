class CountriesController < ApplicationController

  def leagues 
     @country = Country.find_by_name params[:country]

     respond_to do |format|
        format.json { render json: @country.leagues.where("priority=0"), :params=>{:country_id => @country.id}}
     end
  end


  def events
     @country = Country.find_by_name params[:country]

     respond_to do |format|
        format.json { render json: @country.upcoming_events, :include => [:teams]}
     end
  end

end
