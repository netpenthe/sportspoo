class Event < ActiveRecord::Base

  belongs_to :home_team, :class_name=>"Team"
  belongs_to :away_team, :class_name=>"Team"
  belongs_to :league
  belongs_to :sport

end
