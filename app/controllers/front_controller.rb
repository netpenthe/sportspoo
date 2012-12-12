class FrontController < ApplicationController

  def index
    @events = Event.where(["(league_id = 18 or league_id=6 or league_id=38 or league_id=2) 
                             and start_date > ? and start_date < ?", Time.now,Time.now+3.days]).order("start_date ASC")
  end

  def leagues
    @leagues = League.order("name ASC")
  end

  def teams
    @teams =  Team.order("name ASC")
  end
end