class Country < ActiveRecord::Base
  attr_accessible :code, :name

  has_many :leagues, :through=>:country_leagues
end
