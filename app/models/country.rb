class Country < ActiveRecord::Base

  attr_accessible :code, :name

  has_many :leagues, :through=>:countryleagues, :order=>"name DESC"
  has_many :countryleagues

end
