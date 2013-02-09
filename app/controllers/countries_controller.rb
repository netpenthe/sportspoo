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
        format.json { render json: @country.leagues, :include=> { :events => { :include=> :teams}},:params=>{:country_id => @country.id}}
     end
  end

end
