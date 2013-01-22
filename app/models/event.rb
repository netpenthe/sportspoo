class Event < ActiveRecord::Base

include ActionView::Helpers::DateHelper
  #belongs_to :home_team, :class_name=>"Team"
  #belongs_to :away_team, :class_name=>"Team"

  has_many :home_teams, :class_name=>"Team", :through=>:event_teams, :source=>:team, :conditions=>"location_type_id = 1"
  has_many :away_teams, :class_name=>"Team", :through=>:event_teams, :source=>:team, :conditions=>"location_type_id = 2"

  belongs_to :league
  belongs_to :sport

  has_many :teams, :through=>:event_teams

  has_many :event_teams

  #external event id like betfair/pinnacle etc..
  has_many :external_events

  alias_method :xleague, :league
  alias_method :league, :xleague

  def home_team
    home_teams.first
  end

  def away_team
    away_teams.first
  end

  def as_json(options ={})
    h = super(options)
    h[:league] = league.name
    h[:time_in_words] = distance_of_time_in_words_to_now self.start_date
    h
  end
end
