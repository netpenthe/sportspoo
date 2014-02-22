require 'date'

namespace :sanfl do

  task :update_fixtures => :environment do

      file = File.open("custom/sanfl.txt")

      str_date = ""

      sport = Sport.find_or_create_by_name("Football - Australian")
      league = League.find_or_create_by_name_and_sport_id("SANFL",sport.id)


      file.each do |line|

        if line.include?("day") || line.include?("Saturday") || line.include?("Sunday") || line.include?("Monday")
          #get the date/day
        	str_date = line.chomp + " ,2014 , "
        elsif line.size < 3 || line.include?("ROUND")
           #ignore
        else

        	parts = line.chomp.split(" v ")
        	home_team = parts[0]
        	ground = "" 
        	if parts[1].include?("West") ||  parts[1].include?("North") || parts[1].include?("Central") || parts[1].include?("Port") || parts[1].include?("South")
        		away_team = parts[1].split(" ")[0] + " " + parts[1].split(" ")[1]
        		#parts[1].split(" ")[2..parts[1].split(" ").length-2].collect{|word| ground = ground + " " + word}
        		time = parts[1].split(" ").last

              #cstHoursOffset = 9.5
              #cstOffset = Rational(cstHoursOffset, 24) 
        		dt = (DateTime.parse(str_date+time + " +9:30")) #+ (cstHoursOffset/24.0)).new_offset(cstOffset)
        	else
        		away_team = parts[1].split(" ")[0]  		
        		time = parts[1].split(" ").last
        		dt = (DateTime.parse(str_date+time + " +9:30")) #+ (cstHoursOffset/24.0)).new_offset(cstOffset)
        	end

          event = Event.create(:sport_id=>sport.id,:league_id=>league.id,:start_date=>dt, :end_date=>dt+2.hours)

          home = Team.find_by_name home_team
          if home.blank?
            puts "creating #{home_team}"
            home = Team.create(:name=>home_team, :sport_id=>sport.id)
          end

          away = Team.find_by_name away_team    
          if away.blank?
            puts "creating #{away_team}"
            away = Team.create(:name=>away_team, :sport_id=>sport.id)
          end

          EventTeam.create(:event_id=>event.id,:team_id=>home.id, :location_type_id=>1)
          EventTeam.create(:event_id=>event.id,:team_id=>away.id, :location_type_id=>2)

          puts "#{home_team} , #{away_team} , #{dt}"
        end
      end

  end
end

