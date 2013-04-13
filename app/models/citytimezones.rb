class Citytimezones < ActiveRecord::Base
  attr_accessible :city, :country, :latitude, :longitude, :tz, :tz_detail
end
