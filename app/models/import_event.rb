class ImportEvent < ActiveRecord::Base
  attr_accessible :dtend, :dtstart, :location, :summary, :import_id
end
