namespace :betradar do

  task :sync => :environment do
    file = File.open("data/betradar.xml", "rb")
    file_contents = file.read
    data = BetRadar::Event.parse file_contents

    #puts data.class.to_s

    data.each do |event|
      unless event.team2.blank?
        puts event.type
        #ventID
        #puts event.eventName
        puts event.date
        puts event.time
        puts DateTime.strptime("#{event.date} #{event.time}", "%d/%m/%Y %H:%M")
        puts event.team1
        puts event.team2
        puts event.sportname
        puts event.league
        puts "----"

        start_date = DateTime.strptime("#{event.date} #{event.time} CET", "%d/%m/%Y %H:%M %Z")
        
        sport = Sport.first :conditions=>["name = ?", event.sportname]
        sport = Sport.create(:name=>event.sportname, :betradar_id=>event.sportID) if  sport.blank?

        league = League.first :conditions=>["name = ?", event.league]
        league = League.create(:name=>event.league, :betradar_id=>event.leagueID) if league.blank?

        event.team1 = event.team1.force_encoding('UTF-8')
        event.team2 = event.team2.force_encoding('UTF-8')

        puts event.team1
        puts event.team2.encoding
        
        team1 = Team.first :conditions=>["name = ?", event.team1]
        team1 = Team.create(:name=>event.team1, :betradar_id=>event.team1ID) if team1.blank?

        team2 = Team.first :conditions=>["name = ?", event.team2]
        team2 = Team.create(:name=>event.team2, :betradar_id=>event.team2ID) if team2.blank?

        event = Event.find :first,
                           :conditions=>["home_team_id=? and away_team_id=? and DATE_FORMAT(start_date, '%Y-%m-%d')='#{start_date.to_date.to_s}'",
                                                    team1.id,team2.id]

        if event.blank?

          puts "didn't find team1 = #{team1.id} team2 = #{team2.id} start_date = #{start_date}"
          
          event = Event.create :start_date=>start_date, :home_team_id=>team1.id,
                             :away_team_id=>team2.id, :league_id =>league.id, :sport_id=>sport.id
        end

      end

    end

  end

end