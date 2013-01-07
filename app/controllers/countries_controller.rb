class CountriesController < ApplicationController

  def leagues 
     @country = Country.find_by_name params[:country]

     respond_to do |format|
      format.json { render json: @country.leagues, :include => { :events => {:include => :teams}}}
     end
  end

end
