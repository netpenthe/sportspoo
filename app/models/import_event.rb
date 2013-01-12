class ImportEvent < ActiveRecord::Base
  attr_accessible :dtend, :dtstart, :location, :summary, :import_id, :uid

  belongs_to :import
  has_one :event

  
  def summary_filtered
    unless import.filter_out_summary.blank?
      parts = import.filter_out_summary.split(",")
      if parts.count<2
        summary.gsub!(import.filter_out_summary,"")
      else
        parts.each do |part|
          summary.gsub!(part,"")
        end
      end
    end
    summary
  end
  

  def home_team
    teams = summary_filtered.split(import.split_summary_on)
    return ImportEvent.clean teams[0],import.filter_out_summary if import.home_team_first
    return ImportEvent.clean teams[1],import.filter_out_summary
  end

  
  def away_team
    teams = summary_filtered.split(import.split_summary_on)
    return ImportEvent.clean teams[1],import.filter_out_summary if import.home_team_first
    return ImportEvent.clean teams[0],import.filter_out_summary
  end

  
  
  def self.filter name
    return name.gsub(/\d+/,"").chomp.lstrip.rstrip
  end


  def self.filter_out name, filter
    unless filter.blank?
      parts = filter.split(",")

      if parts.count<2
        puts name
        puts filter
        puts name.gsub(filter,"")
        return name.gsub(filter,"")
      else
        parts.each do |part|
          name.gsub!(part,"")
        end
      end
    end
    
    return name
    
  end


  def self.clean name, filter
    return (self.filter_out self.filter(name), filter).rstrip.lstrip
  end



end
