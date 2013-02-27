class Sport < ActiveRecord::Base

  #has_many :leagues, :through=>:events

  has_many :events
  has_many :leagues

  acts_as_taggable
  acts_as_taggable_on :nicknames,:shortnames

  def all_names
    "#{shortname_list} | #{nickname_list}"
  end


end
