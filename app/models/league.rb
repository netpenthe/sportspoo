class League < ActiveRecord::Base

  belongs_to :sport
  has_many :events


  def as_json(options ={})
    options[:except] = [:updated_at, :created_at]
    h = super(options)
    h[:sport] = sport.name unless sport.blank?
    h[:priority] = self.priority options[:params][:country_id] unless options[:params].blank?
    h
  end

  def priority country_id
    countryleague = Countryleague.where(["country_id=? and league_id=?",country_id,self.id]).first
    countryleague.priority
  end

  def self.search_name(q,num_limit)
    q = "%#{q}%"
    League.select('distinct leagues.*').where('name LIKE ?', q ).limit(num_limit)
  end


end
