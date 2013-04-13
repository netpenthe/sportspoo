class Event < ActiveRecord::Base

  include ActionView::Helpers::DateHelper

  acts_as_taggable

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
  
  #scope :upcoming_events, lab:where=>['start_date > ?', Time.now.utc - 1.hour], :order=>'start_date', :limit=>25

  def self.upcoming_events(league_id)
    where('start_date > ? and league_id = ?',Time.now,league_id).order("start_date").limit(25)
  end 

  def self.upcoming_events_for_user(user, limit)
    where('start_date > ? and start_date < ? and (league_id in (?) OR sport_id in (?) OR team_id in (?))',Time.now,Time.now+28.days,user.leagues.map{|l|l.preference_id}, user.sports.map{|l|l.preference_id},user.teams.map{|l|l.preference_id}).joins('left join event_teams on event_teams.event_id = events.id').order("start_date").limit(limit).group(:id)
    #where('start_date > ? and start_date < ? ',Time.now,Time.now+7.days).order(("start_date").limit(25)
#,:order=>:start_date,:joins=>"left join event_teams on event_teams.team_id = events.id",:limit=>limit, :include=>[:event_teams, :teams])
    #Event.find(:all, :conditions=>['start_date > ? and start_date < ? and (league_id = ? OR sport_id = ? OR team_id = ?)',Time.now,Time.now+7.days,[user.leagues.map{|l|l.preference_id}.join(",")], [user.sports.map{|l|l.preference_id}.join(",")],[user.teams.map{|l|l.preference_id}.join(",")]],:order=>:start_date,:joins=>"left join event_teams on event_teams.team_id = events.id",:limit=>limit, :include=>[:event_teams, :teams])
  end

  def self.upcoming_events_for_user_by_team(user, team_id, limit)
    where('start_date > ? and start_date < ? and team_id = ?',Time.now,Time.now+28.days,team_id).joins('left join event_teams on event_teams.event_id = events.id').order("start_date").limit(25)
  end
  
  def home_team
    home_teams.first
  end

  def away_team
    away_teams.first
  end


  def as_json(options ={})
    options[:except] ||= :import_id
    options[:except] ||= :created_at
    options[:except] ||= :import_event_id
    h = super(options)
    h[:league] = league.name
    h[:time_in_words] = distance_of_time_in_words_to_now self.start_date
    h[:running] = self.start_date < Time.now ? true : false
    h[:quick_datetime] = self.start_date.strftime('%a%l:%M%P')

    #not used
    h.delete(:import_id)
    h.delete(:created_at)  
    h.delete(:import_event_id)  
    h.delete(:location_id)  
    h.delete(:updated_at)  

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

  def countdown
    return distance_of_time_in_words_to_now self.start_date
  end

  def league_name
    return league.name
  end

  def league_label_colour
    return league.label_colour || "#666666"
  end


  def live
    unless end_date.blank?
      return true if Time.now > self.start_date && Time.now < self.end_date
    else
      return true if Time.now > self.start_date && Time.now < (self.start_date + 2.hours)
    end
    return false
  end
  
end
