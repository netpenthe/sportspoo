class CountriesController < ApplicationController

  def leagues 
     @country = Country.find_by_name params[:country]

     respond_to do |format|
        format.json { render json: @country.leagues, :params=>{:country_id => @country.id}}
     end
  end


  def events
     @country = Country.find_by_name params[:country]

     respond_to do |format|
        format.json { render json: @country.upcoming_events, :include => [:teams]}
        #format.json { render json: @country.upcoming_events.where("priority=0"), :include => [:teams]}
     end
  end

end
