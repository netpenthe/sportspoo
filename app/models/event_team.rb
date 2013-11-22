class EventTeam < ActiveRecord::Base
  attr_accessible :event_id, :location_id, :location_type_id, :team_id, :match_odds
  belongs_to :event
  belongs_to :team
end
