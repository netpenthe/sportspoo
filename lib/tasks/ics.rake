
namespace :ics do

  task :import => :environment do

    league = League.find_by_name "MLB"
    league = League.new(:name => "MLB").save if league.blank? 

    sport = Sport.find_by_name "Baseball"

    File.open("data/cubs_schedule.ics", "r") do |file_handle|

      components = RiCal.parse(file_handle)

      components.each do |component|
         component.events.each do |evnt|
            puts "#{evnt.summary} on #{evnt.dtstart}"
            team=evnt.summary.split(" at ")
            puts team[0]
            puts team[1]

            team1 = Team.first :conditions=>["name = ?", team[0]]
            team1 = Team.create(:name=>team[0]) if team1.blank?
            team2 = Team.first :conditions=>["name = ?", team[1]]
            team2 = Team.create(:name=>team[1]) if team2.blank?
    
            event = Event.find :first,
                           :conditions=>["home_team_id=? and away_team_id=? and DATE_FORMAT(events.start_date, '%Y-%m-%d')='#{evnt.dtstart.to_date.to_s}'",
                                                    team2.id,team1.id]

           if event.blank?
              puts "didn't find team1 = #{team1.id} team2 = #{team2.id} start_date = #{evnt.dtstart}"

              event = Event.create :start_date=>evnt.dtstart, :home_team_id=>team2.id,
                             :away_team_id=>team1.id, :league_id =>league.id, :sport_id=>sport.id
           end

         end
      end

    end

  end
end
