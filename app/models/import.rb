class Import < ActiveRecord::Base
  attr_accessible :filter_out_summary, :league_name, :split_summary_on, :sport_name,:home_team_first

  attr_accessible :ics
  has_attached_file :ics

  
  def import_events_count
    self.import_events.count
  end

  has_many :import_events, :dependent => :destroy

  has_many :imported_events, :class_name=>"Event",  :dependent => :destroy
  has_many :imported_sports, :class_name=>"Sport",  :dependent => :destroy
  has_many :imported_leagues, :class_name=>"League", :dependent => :destroy
  has_many :imported_teams, :class_name=>"Team", :dependent => :destroy


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
