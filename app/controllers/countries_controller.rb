class CountriesController < ApplicationController

  def xleagues 
     @country = Country.find_by_name params[:country]

     respond_to do |format|
      if params[:events].to_i==0
        format.json { render json: @country.leagues }
      else
        format.json { render json: @country.leagues, :include => { :events => {:include => :teams}}}
      end
     end
  end


  def leagues
     @country = Country.find_by_name params[:country]

     respond_to do |format|
      format.json { render json: @country.leagues, :include => { :events => {:include => :teams}}}
     end
  end

end
