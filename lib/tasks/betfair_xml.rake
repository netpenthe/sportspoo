require 'open-uri'


namespace :betfair_xml do

  task :basketball => :environment do
    
    puts "getting data from http://auscontent.betfair.com/partner/marketData_loader.asp?fa=ss&id=7522&SportName=Basketball&Type=BL"
    file = open("http://auscontent.betfair.com/partner/marketData_loader.asp?fa=ss&id=7522&SportName=Basketball&Type=BL",
            "User-Agent" => "Mozilla/5.0 (Windows; U; Windows NT 5.1; id) AppleWebKit/522.11.3 (KHTML, like Gecko) Version/3.0 Safari/522.11.3")

    #file = File.open("data/betfair-basketball.xml", "rb")

    file_contents = file.read
    
    betfair = BetFair::Betfair.parse file_contents

    data = BetFair::Event.parse file_contents

    data.each do |event|
      event.sub_events.each do |sub|
        if sub.title=="Match Odds"
          #name => NBL 2012/13/Round 17 - 01 February/Adelaide v Wollongong
          parts = event.name.split("/")

          puts "Sport: #{betfair.sport}"
          sport = Sport.find_or_create_by_name(betfair.sport)

          puts "League: #{parts[0].split(" ")[0].chomp}"
          league = League.find_or_create_by_name(parts[0].split(" ")[0].chomp)

          puts "Event name: #{parts[3]}"
          puts "Betfair id: #{sub.betfair_id}"
          puts "Event date: #{event.date}"
          puts "Event time: #{sub.time}"

          evnt = nil

          external_event = ExternalEvent.where(:site=>"BetfairXML", :external_key=>sub.betfair_id).first
          
          if external_event.blank?
            
            puts "creating"
            evnt = Event.create(:sport_id=>sport.id,:league_id=>league.id,:start_date=>"#{event.date} #{sub.time}")
            ExternalEvent.create(:site=>"BetfairXML", :external_key=>sub.betfair_id, :event_id=>evnt.id)

            puts "Participants:"

            puts " " + sub.selections[0].name
            home_team = Team.where(:name=>sub.selections[0].name).first
            home_team = Team.create(:name=>sub.selections[0].name,:sport_id=>sport.id) if home_team.blank?

            puts " " + sub.selections[1].name
            away_team = Team.where(:name=>sub.selections[1].name).first
            away_team = Team.create(:name=>sub.selections[1].name,:sport_id=>sport.id) if away_team.blank?

            EventTeam.create(:event_id=>evnt.id,:team_id=>home_team.id, :location_type_id=>1)
            EventTeam.create(:event_id=>evnt.id,:team_id=>away_team.id, :location_type_id=>2)

            puts "------------"

          else
            puts "updating"
            evnt = external_event.event
            #Event.update_attributes
          end
          
        end

      end

    end

  end


end
