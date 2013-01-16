class LeaguesController < ApplicationController

  def all

     respond_to do |format|
      #format.json { render json: @country.upcoming_events}
      #format.json { render json: League.all, :include => [:sports]}
      format.json { render json: League.all} 
     end
  end

  def country
     country = Country.find_by_name(params[:country])
     respond_to do |format|
      #format.json { render json: @country.upcoming_events}
      #format.json { render json: League.all, :include => [:sports]}
      format.json { render json: country.leagues} 
     end
  end
end
