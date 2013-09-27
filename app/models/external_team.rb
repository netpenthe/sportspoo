class ExternalTeam < ActiveRecord::Base
  attr_accessible :external_key, :site, :team_id, :name

  belongs_to :team
end
