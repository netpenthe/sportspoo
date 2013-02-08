class CountriesController < ApplicationController


  def leagues 
     @country = Country.find_by_name params[:country]

     respond_to do |format|
        format.json { render json: @country, :include => { :countryleagues => { :include=>:league } } }
     end
  end


  def events
     @country = Country.find_by_name params[:country]

     respond_to do |format|
        format.json { render json: @country, :include => {  :countryleagues => {:include => {:league => { :include=> { :events => { :include=> :teams}}}}}}}
     end
  end

end
