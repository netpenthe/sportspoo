class Event < ActiveRecord::Base

include ActionView::Helpers::DateHelper
  
  has_many :home_teams, :class_name=>"Team", :through=>:event_teams, :source=>:team, :conditions=>"location_type_id = 1"
  has_many :away_teams, :class_name=>"Team", :through=>:event_teams, :source=>:team, :conditions=>"location_type_id = 2"

  belongs_to :league
  belongs_to :sport
  belongs_to :location

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


  def self.find_for_site_and_key site, key
    ee = ExternalEvent.where(["site = ? and external_key = ?",site,key]).first
    return ee.event unless ee.blank?
    return nil
  end

  def display_name
    return name unless name.blank?
    return "#{home_team.name} vs #{away_team.name}"
  end

end
