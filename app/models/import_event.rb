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
    teams = Array.new
    count = 0
    if import.split_summary_on.include? "|"
      parts = import.split_summary_on.split("|")
      parts.each do |prt|
        count = count + 1
        if summary_filtered.include?(prt)
          teams = summary_filtered.split(prt)
          break
        end
      end
    else
      teams = summary_filtered.split(import.split_summary_on)
    end
    
    return ImportEvent.clean teams[0],import.filter_out_summary if import.home_team_first || count == 1
    return ImportEvent.clean teams[1],import.filter_out_summary
  end

  
  def away_team
    teams = Array.new
    count = 0
    if import.split_summary_on.include? "|"
      parts = import.split_summary_on.split("|")
      parts.each do |prt|
        count = count + 1
        if summary_filtered.include?(prt)
          teams = summary_filtered.split(prt)
          break
        end
      end
    else
      teams = summary_filtered.split(import.split_summary_on)
    end

    return ImportEvent.clean teams[1],import.filter_out_summary if import.home_team_first || count == 0
    return ImportEvent.clean teams[0],import.filter_out_summary
  end

  
  
  def self.filter name
    return name.gsub(/\d+/,"").chomp.lstrip.rstrip unless name.blank?
    return " "
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
    return (self.filter_out self.filter(name), filter).rstrip.lstrip.titleize
  end



end
