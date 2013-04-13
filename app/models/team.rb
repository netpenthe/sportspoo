class Team < ActiveRecord::Base

  #check if team exists in this sport
  belongs_to :sport

  acts_as_taggable
  acts_as_taggable_on :nicknames, :shortnames
  
  
  def self.find_for_sport name, sport_id
    Team.joins("join event_teams on event_teams.team_id = teams.id
                                   join events on events.id = event_teams.event_id").where(["events.sport_id = ? and teams.name = ?",sport_id,name]).first
  end
 
  def as_json(options ={})
    options[:except] = [:import_id, :created_at,:updated_at]
    h = super(options)
    h[:sport_name] = self.sport.present? ? self.sport.name : 'sprt' 
    h
  end

  def all_names
    "#{shortname_list} | #{nickname_list}"
  end

  def self.search_name_and_tags(q,num_limit)
    q = "%#{q}%"
    Team.select('distinct teams.*').joins("LEFT JOIN taggings on teams.id = taggings.taggable_id").joins("LEFT JOIN tags on tags.id = taggings.tag_id").where('teams.name LIKE ? OR tags.name LIKE ?', q,q ).limit(num_limit)
  end

end
