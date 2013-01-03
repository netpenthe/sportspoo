class SportsController < ApplicationController

  def index
     @sports = Sport.includes(:leagues => :events).where(["events.start_date < ?", 4.days.ago])
     respond_to do |format|
      format.json { render json: @sports, :include => { :leagues => {:include => :events }  }}
     end
  end

end
