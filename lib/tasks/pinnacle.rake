require 'open-uri'


namespace :pinnacle do

  task :sync => :environment do
    file = File.open("data/pinnacle.xml", "rb")
    file_contents = file.read
    data = Pinnacle::Event.parse file_contents

    puts data.class.to_s

    data.each do |event|
      if event.participants.count < 4 && !event.league.include?("Props")
        puts event.sporttype
        puts event.league

        start_date =  DateTime.strptime("#{event.event_datetimeGMT}", "%Y-%m-%d %H:%M")
        puts start_date
   
        team1 = nil
        team2 = nil

        event.participants.each do |team|
            puts team.participant_name
            if team.visiting_home_draw == "Home"
               team1 = Team.first :conditions=>["name = ?", team.participant_name]
               team1 = Team.create(:name=>team.participant_name) if team1.blank?
            elsif team.visiting_home_draw != "Draw"
               team2 = Team.first :conditions=>["name = ?", team.participant_name]
               team2 = Team.create(:name=>team.participant_name) if team2.blank?
            end
        end

        puts "----"
        
        sport = Sport.first :conditions=>["name = ?", event.sporttype]
        sport = Sport.create(:name=>event.sporttype)  if  sport.blank?

        league = League.first :conditions=>["name = ?", event.league]
        league = League.create(:name=>event.league,:sport_id=>sport.id) if league.blank?

        #event.team1 = event.team1.force_encoding('UTF-8')
        #event.team2 = event.team2.force_encoding('UTF-8')
        
        if !team1.blank? && !team2.blank?
          #puts "looking for  team1 = #{team1.id} team2 = #{team2.id} start_date = #{start_date}"
          #event = Event.find :first,
          #                 :conditions=>["home_team_id=? and away_team_id=? and DATE_FORMAT(start_date, '%Y-%m-%d')='#{start_date.to_date.to_s}'",
          #                                          team1.id,team2.id]

        #if event.blank?
          puts "didn't find team1 = #{team1.id} team2 = #{team2.id} start_date = #{start_date}"
          
          event = Event.create :start_date=>start_date,
                          :league_id =>league.id, :sport_id=>sport.id
          eventteam = EventTeam.create :event_id=>event.id, :team_id=>team1.id, :location_type_id=>1
          eventteam = EventTeam.create :event_id=>event.id, :team_id=>team2.id, :location_type_id=>2
 
        #end
       end

      end

    end

  end



  task :tennis => :environment do
    
    puts "getting data from http://xml.pinnaclesports.com/pinnacleFeed.aspx"
    file = open("http://xml.pinnaclesports.com/pinnacleFeed.aspx")

    file_contents = file.read
    data = Pinnacle::Event.parse file_contents

    data.each do |event|
      if event.participants.count < 4 && !event.league.include?("Props") && event.IsLive == "No" && event.sporttype=="Tennis"

        start_date =  DateTime.strptime("#{event.event_datetimeGMT}", "%Y-%m-%d %H:%M")

        team1 = nil
        team2 = nil

        event.participants.each do |team|
            break if team.participant_name.include?("Sets)")

            puts team.participant_name

            if team.visiting_home_draw == "Home"
               team1 = Team.first :conditions=>["name = ?", team.participant_name]
               team1 = Team.create(:name=>team.participant_name) if team1.blank?
            elsif team.visiting_home_draw != "Draw"
               team2 = Team.first :conditions=>["name = ?", team.participant_name]
               team2 = Team.create(:name=>team.participant_name) if team2.blank?
            end
        end

        puts "----"

        sport = Sport.first :conditions=>["name = ?", event.sporttype]
        sport = Sport.create(:name=>event.sporttype)  if  sport.blank?

        league = League.first :conditions=>["name = ?", event.league]
        league = League.create(:name=>event.league,:sport_id=>sport.id) if league.blank?

        #event.team1 = event.team1.force_encoding('UTF-8')
        #event.team2 = event.team2.force_encoding('UTF-8')

        if !team1.blank? && !team2.blank?

          #try to see if we already have this event
          #evnt = Event.find :first,
          #                 :conditions=>["home_team_id=? and away_team_id=? and DATE_FORMAT(start_date, '%Y-%m-%d')='#{start_date.to_date.to_s}'",
          #
          #                                                                                   team1.id,team2.id]
          #if evnt.blank?

          evnt = Event.find_for_site_and_key "Pinnacle", event.gamenumber
          
          unless evnt.blank?
            puts "updating time for event id #{evnt.id}"
            evnt.start_date = start_date
            evnt.save
          else
            puts "creating event"
            evnt = Event.create :start_date=>start_date, :league_id =>league.id, :sport_id=>sport.id
            eventteam = EventTeam.create :event_id=>evnt.id, :team_id=>team1.id, :location_type_id=>1
            eventteam = EventTeam.create :event_id=>evnt.id, :team_id=>team2.id, :location_type_id=>2
            ExternalEvent.create(:event_id=>evnt.id, :site=>"Pinnacle", :external_key=>event.gamenumber)
          end

       end

      end

    end

  end



end
