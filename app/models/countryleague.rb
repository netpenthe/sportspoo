class Countryleague < ActiveRecord::Base

  attr_accessible :country_id, :league_id

  belongs_to :country
  belongs_to :league

end
