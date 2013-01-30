require 'open-uri'


namespace :betfair_xml do

  task :basketball => :environment do
    
    puts "getting data from http://auscontent.betfair.com/partner/marketData_loader.asp?fa=ss&id=7522&SportName=Basketball&Type=BL"
    #file = open("http://auscontent.betfair.com/partner/marketData_loader.asp?fa=ss&id=7522&SportName=Basketball&Type=BL")

    file = File.open("data/betfair-basketball.xml", "rb")
    file_contents = file.read
    
    data = BetFair::Event.parse file_contents

    data.each do |event|
      event.sub_events.each do |sub|
        #puts sub.title
        if sub.title=="Match Odds"
          puts event.name
          puts event.date
          puts sub.time
          sub.selections.each do |selection|
            puts " " + selection.name
          end
        end
      end
    end

  end

end
