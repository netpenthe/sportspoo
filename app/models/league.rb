class League < ActiveRecord::Base

  belongs_to :sport
  has_many :events

  def as_json(options ={})
    h = super(options)
    h[:sport] = sport.name unless sport.blank?
    h[:priority] = self.priority options[:params][:country_id]
    h
  end

  def priority country_id
    puts "getting priority"
    countryleague = Countryleague.where(["country_id=? and league_id=?",country_id,self.id]).first
    countryleague.priority 
  end

end
