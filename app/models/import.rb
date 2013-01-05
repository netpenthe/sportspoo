class Import < ActiveRecord::Base
  attr_accessible :filter_out_summary, :league_name, :split_summary_on, :sport_name

  attr_accessible :ics
  has_attached_file :ics
end
