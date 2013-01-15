class CountriesController < ApplicationController

  def leagues 
     @country = Country.find_by_name params[:country]

     respond_to do |format|
      unless params[:events].blank?
        format.json { render json: @country.leagues }
      else
        format.json { render json: @country.leagues, :include => { :events => {:include => :teams}}}
      end
      
     end
  end

end
