class ImportEvent < ActiveRecord::Base
  attr_accessible :dtend, :dtstart, :location, :summary, :import_id

  belongs_to :import

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
end
