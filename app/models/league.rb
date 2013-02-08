class League < ActiveRecord::Base

  belongs_to :sport
  has_many :events

  def as_json(options ={})
    h = super(options)
    h[:sport] = sport.name unless sport.blank?
    h
  end

end
