class SportsController < ApplicationController

  def index
     @sports = Sport.includes(:leagues => :events).where(["events.start_date < ? and events.start_date > ?", Time.now + 4.days, Time.now])
     respond_to do |format|
      format.json { render json: @sports, :include => { :leagues => {:include => :events }  }}
     end
  end

end
