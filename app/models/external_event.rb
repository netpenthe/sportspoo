class ExternalEvent < ActiveRecord::Base
  attr_accessible :event_id, :external_key, :site
end
