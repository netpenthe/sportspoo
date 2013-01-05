class CountriesController < ApplicationController

  def leagues 
     @country = Country.find_by_name params[:country]

     respond_to do |format|
      format.json { render json: @country.leagues }
     end
  end

end
