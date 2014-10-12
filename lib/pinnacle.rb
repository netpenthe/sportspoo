# #require 'happymapper'

# module Pinnacle 

#   class Participant
#     include HappyMapper
#     tag "participant"
#     element "participant_name",String
#     element "visiting_home_draw",String
#   end

#   class Event
#     include HappyMapper
#     tag "event"
#     element "gamenumber", Integer
#     element "event_datetimeGMT", String
#     element "sporttype", String
#     element "league", String
#     element "IsLive", String
#     has_many :participants, Participant
#   end

# end
