class Sport < ActiveRecord::Base

  #has_many :leagues, :through=>:events

  has_many :events
  has_many :leagues

end
