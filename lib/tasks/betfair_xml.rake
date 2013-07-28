require 'open-uri'


namespace :betfair_xml do

  task :footballcups => :environment do
    
    puts "getting data from http://auscontent.betfair.com/partner/marketData_loader.asp?fa=ss&id=7522&SportName=Basketball&Type=BL"
    #file = open("http://www.betfair.com/partner/marketData_loader.asp?fa=ss&id=1&SportName=Soccer&Type=B",
    #        "User-Agent" => "Mozilla/5.0 (Windows; U; Windows NT 5.1; id) AppleWebKit/522.11.3 (KHTML, like Gecko) Version/3.0 Safari/522.11.3")
    
    file = open("data/betfair-soccer.xml","rb")

    file_contents = file.read
    file_contents.gsub!("version=\"1.0\""," version=\"1.0\" encoding=\"ISO-8859-1\"")

    betfair = BetFair::Betfair.parse file_contents
    data = BetFair::Event.parse file_contents

    # English Soccer/FA Cup/Fixtures 27 February/Middlesbrough v Chelsea" date="27/02/2013"

    data.each do |event|
      event.sub_events.each do |sub|
        if sub.title=="DRAW NO BET"

          parts = event.name.split("/")

          evnt = {}
          evnt[:sport_name] = "Football"
          evnt[:league_name] = parts[1].chomp
          evnt[:site] = "BetfairXML"
          evnt[:external_key] = sub.betfair_id
          evnt[:start_date] = "#{event.date} #{sub.time}"
          evnt[:end_date] = ""
          evnt[:home_team_first] = true
          evnt[:teams] = []
          sub.selections.each do |selection|
             evnt[:teams] << selection.name
          end

          create_or_update_event(evnt) if evnt[:league_name].include?("FA Cup") || evnt[:league_name].include?("Scottish Cup") || evnt[:league_name].include?("Spanish Cup")
          
        end

      end

    end

  end
 




  task :basketball => :environment do
    
    puts "getting data from http://auscontent.betfair.com/partner/marketData_loader.asp?fa=ss&id=7522&SportName=Basketball&Type=BL"
    file = open("http://www.betfair.com/partner/marketData_loader.asp?fa=ss&id=7522&SportName=Basketball&Type=B",
            "User-Agent" => "Mozilla/5.0 (Windows; U; Windows NT 5.1; id) AppleWebKit/522.11.3 (KHTML, like Gecko) Version/3.0 Safari/522.11.3")

    file_contents = file.read   
    betfair = BetFair::Betfair.parse file_contents
    data = BetFair::Event.parse file_contents

    data.each do |event|
      event.sub_events.each do |sub|
        if sub.title=="Moneyline"

          parts = event.name.split("/")

          evnt = {}
          evnt[:sport_name] = betfair.sport
          evnt[:league_name] = parts[0].split("2012")[0].chomp
          evnt[:site] = "BetfairXML"
          evnt[:external_key] = sub.betfair_id
          evnt[:start_date] = "#{event.date} #{sub.time}"
          evnt[:end_date] = ""
          evnt[:home_team_first] = true
          evnt[:teams] = []
          sub.selections.each do |selection|
             evnt[:teams] << selection.name
          end

          create_or_update_event(evnt) if !evnt[:league_name].include?("NCAA")
          
        end

      end

    end

  end



  task :nbl => :environment do

    puts "getting data from http://auscontent.betfair.com/partner/marketData_loader.asp?fa=ss&id=7522&SportName=Basketball&Type=BL"
    file = open("http://auscontent.betfair.com/partner/marketData_loader.asp?fa=ss&id=7522&SportName=Basketball&Type=B",
            "User-Agent" => "Mozilla/5.0 (Windows; U; Windows NT 5.1; id) AppleWebKit/522.11.3 (KHTML, like Gecko) Version/3.0 Safari/522.11.3")

    file_contents = file.read
    betfair = BetFair::Betfair.parse file_contents
    data = BetFair::Event.parse file_contents

    data.each do |event|
      event.sub_events.each do |sub|
        if sub.title=="Match Odds"

          parts = event.name.split("/")

          evnt = {}
          evnt[:sport_name] = betfair.sport
          evnt[:league_name] = parts[0].split(" ")[0].chomp
          evnt[:site] = "BetfairXML"
          evnt[:external_key] = sub.betfair_id
          evnt[:start_date] = "#{event.date} #{sub.time}"
          evnt[:end_date] = ""
          evnt[:home_team_first] = true
          evnt[:teams] = []
          sub.selections.each do |selection|
             evnt[:teams] << selection.name
          end

          create_or_update_event(evnt)

        end

      end

    end

  end



 task :cricket => :environment do

    puts "getting data from http://www.betfair.com/partner/marketData_loader.asp?fa=ss&id=4&SportName=Cricket&Type=B"
    file = open("http://www.betfair.com/partner/marketData_loader.asp?fa=ss&id=4&SportName=Cricket&Type=B",
            "User-Agent" => "Mozilla/5.0 (Windows; U; Windows NT 5.1; id) AppleWebKit/522.11.3 (KHTML, like Gecko) Version/3.0 Safari/522.11.3")

    file_contents = file.read
    betfair = BetFair::Betfair.parse file_contents
    data = BetFair::Event.parse file_contents

    data.each do |event|
      event.sub_events.each do |sub|
        if sub.title=="Match Odds DRAW NO BET"

          parts = event.name.split("/")

          evnt = {}
          evnt[:sport_name] = betfair.sport
          evnt[:league_name] = parts[1].chomp
          evnt[:site] = "BetfairXML"
          evnt[:external_key] = sub.betfair_id

          start_date = DateTime.parse("#{event.date} #{sub.time}")
          end_date = start_date + 9.hours

          evnt[:start_date] = start_date
          evnt[:end_date] = end_date

          evnt[:home_team_first] = true
          evnt[:teams] = []
          sub.selections.each do |selection|
             evnt[:teams] << selection.name
          end

          create_or_update_event(evnt)

        end

      end

    end

  end




  # def create_or_update_event event

  #   sport = Sport.find_or_create_by_name(event[:sport_name])
  #   league = League.find_or_create_by_name_and_sport_id(event[:league_name],sport.id)

  #   event[:sport_id] = sport.id
  #   event[:league_id] = league.id

  #   external_event = ExternalEvent.where(:site=>event[:site], :external_key=>event[:external_key]).first

  #   if external_event.blank?

  #     puts "creating"
  #     evnt = Event.create(:sport_id=>event[:sport_id],:league_id=>event[:league_id],:start_date=>event[:start_date])
  #     ExternalEvent.create(:site=>event[:site], :external_key=>event[:external_key], :event_id=>evnt.id)

  #     count = 1
  #     event[:teams].each do |team_name|
  #       puts team_name
  #       location_type = count
  #       location_type = 1 if !event[:home_team_first] && count == 2
  #       location_type = 2 if !event[:home_team_first] && count == 1

  #       team = Team.where(:name=>team_name, :sport_id=>sport.id).first
  #       team = Team.create(:name=>team_name,:sport_id=>event[:sport_id]) if team.blank?
  #       EventTeam.create(:event_id=>evnt.id,:team_id=>team.id, :location_type_id=>location_type)
  #       count = count + 1
  #     end

  #   else

  #     puts "updating"
  #     evnt = external_event.event
  #     evnt.update_attributes(:start_date=>event[:start_date])
      
  #   end
    
  # end
  
end
