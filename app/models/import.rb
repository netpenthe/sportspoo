class Import < ActiveRecord::Base
  attr_accessible :filter_out_summary, :league_name, :split_summary_on, :sport_name

  attr_accessible :ics
  has_attached_file :ics

  has_many :import_events

  def import_events_count
    self.import_events.count
  end

  has_many :imported_events, :class_name=>"Event"
  has_many :imported_sports, :class_name=>"Sport"
  has_many :imported_leagues, :class_name=>"League"
  has_many :imported_teams, :class_name=>"Team"

  def imported_events_count
    self.imported_events.count
  end

  def imported_sports_count
    imported_sports.count
  end

  def imported_leagues_count
    imported_leagues.count
  end

  def imported_teams_count
    imported_teams.count
  end

end
