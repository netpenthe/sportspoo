require 'happymapper'

module BetFair

  class Betfair
    include HappyMapper
    tag "betfair"
    attribute "sport", String
  end

  class Selection
    include HappyMapper
    tag "selection"
    attribute "name", String
    attribute 'backp1', String
    attribute "id", String
  end

  class SubEvent
    include HappyMapper
    tag "subevent"
    has_many :selections, Selection
    attribute "time", String
    attribute "betfair_id", String, :tag=>"id"
    attribute "title", String
  end

  class Event
    include HappyMapper
    tag "event"
    attribute "name", String
    attribute "date", String
    has_many :sub_events, SubEvent
  end


end



# http://www.betfair.com/partner/marketdata_xml3.asp
# 
# example http://auscontent.betfair.com/partner/marketData_loader.asp?fa=ss&id=7522&SportName=Basketball&Type=BL
# 
# <betfair sport="Basketball">
#  <event name="NBL 2012/13/Round 17 - 01 February/Adelaide v Wollongong" date="01/02/2013">
#    <subevent title="Match Odds" date="01/02/2013" time="09:00" id="100618588" TotalAmountMatched="0">
#      <selection name="Adelaide 36ers" id="1196397" backp1="1.05" backs1="12.00" layp1="0.00" lays1="0.00" backp2="1.01" backs2="106.24" layp2="0.00" lays2="0.00" backp3="0.00" backs3="0.00" layp3="0.00" lays3="0.00"/>
#      <selection name="Wollongong Hawks" id="1196403" backp1="1.05" backs1="12.00" layp1="0.00" lays1="0.00" backp2="1.01" backs2="106.24" layp2="0.00" lays2="0.00" backp3="0.00" backs3="0.00" layp3="0.00" lays3="0.00"/>
#     </subevent>