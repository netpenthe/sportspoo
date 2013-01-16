class Country < ActiveRecord::Base

  attr_accessible :code, :name

  #has_many :leagues, :through=>:countryleagues, :order=>"name DESC"
  has_many :leagues, :through=>:countryleagues, :order=>"name DESC"
  has_many :events, :through=>:leagues
  has_many :upcoming_events, :source => :events, :through=>:leagues, :conditions=>['start_date > ?', Time.now.utc - 1.hour], :order=>'start_date', :limit=>25
  has_many :countryleagues

end
