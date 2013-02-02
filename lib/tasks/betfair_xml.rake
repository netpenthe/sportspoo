require 'open-uri'


namespace :betfair_xml do

  task :basketball => :environment do
    
    puts "getting data from http://auscontent.betfair.com/partner/marketData_loader.asp?fa=ss&id=7522&SportName=Basketball&Type=BL"
    #file = open("http://auscontent.betfair.com/partner/marketData_loader.asp?fa=ss&id=7522&SportName=Basketball&Type=BL")

    file = File.open("data/betfair-basketball.xml", "rb")

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

          #event = Event.find_or_create(:key=>"Betfair", :id=>sub.betfair_id)

          puts "Participants:"
          sub.selections.each do |selection|
            puts " " + selection.name
          end
          puts "------------"
        end
      end
    end

  end

end
