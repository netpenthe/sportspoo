require 'iconv'

namespace :betfair do

  task :update => :environment do

    urls = {:afl => "http://auscontent.betfair.com/partner/marketData_loader.asp?fa=ss&id=61420&SportName=Australian+Rules&Type=B",
            :mlb => "http://www.betfair.com/partner/marketData_loader.asp?fa=ss&id=7511&SportName=Baseball&Type=B",
            :cricket_uk => "http://www.betfair.com/partner/marketData_loader.asp?fa=ss&id=4&SportName=Cricket&Type=B",
            :cricket_au => "http://auscontent.betfair.com/partner/marketData_loader.asp?fa=ss&id=4&SportName=Cricket&Type=B",
            :gridiron => "http://www.betfair.com/partner/marketData_loader.asp?fa=ss&id=6423&SportName=American+Football&Type=B",
            :football_au => "http://auscontent.betfair.com/partner/marketData_loader.asp?fa=ss&id=1&SportName=Soccer&Type=B",
            :basketball => "http://www.betfair.com/partner/marketData_loader.asp?fa=ss&id=7522&SportName=Basketball&Type=B",
            :basketball_au => "http://auscontent.betfair.com/partner/marketData_loader.asp?fa=ss&id=7522&SportName=Basketball&Type=B",
            :football => "http://www.betfair.com/partner/marketData_loader.asp?fa=ss&id=1&SportName=Soccer&Type=B",
            #:motor=> "http://www.betfair.com/partner/marketData_loader.asp?fa=ss&id=8&SportName=Motor+Sport&Type=B",
            :hockey=> "http://www.betfair.com/partner/marketData_loader.asp?fa=ss&id=7524&SportName=Ice+Hockey&Type=B"
          }

    if Rails.env == "development" 
      urls = {}     
      #urls[:football] =  "#{Rails.root}/data/soccer.xml"
      urls[:afl] = "http://auscontent.betfair.com/partner/marketData_loader.asp?fa=ss&id=61420&SportName=Australian+Rules&Type=B"
      #urls[:afl] = "http://auscontent.betfair.com/partner/marketData_loader.asp?fa=ss&id=61420&SportName=Australian+Rules&Type=B"
      urls[:mlb] = "http://www.betfair.com/partner/marketData_loader.asp?fa=ss&id=7511&SportName=Baseball&Type=B"
      #urls[:gridiron] = "http://www.betfair.com/partner/marketData_loader.asp?fa=ss&id=6423&SportName=American+Football&Type=B"
      # urls[:hockey] = "http://www.betfair.com/partner/marketData_loader.asp?fa=ss&id=7524&SportName=Ice+Hockey&Type=B"
    end

    urls.each do |key,url|
      puts "#{key} -> #{url}"

      file = open(url)

      file_contents = file.read

      file.close

      file_contents = Iconv.conv 'UTF-8', 'iso8859-1', file_contents
      file_contents.gsub!("version=\"1.0\""," version=\"1.0\" encoding=\"ISO-8859-1\"")

      #betfair = BetFair::Betfair.parse file_contents

      data = BetFair::Event.parse file_contents

      data.each do |event|
        event.sub_events.each do |sub|
          evnt = {}
          found_match, evnt[:sport_name],evnt[:league_name], evnt[:teams], duration, home_team_first, evnt[:odds], evnt[:name] = self.send(key.to_s.split("_")[0].to_sym,sub,event)
          if found_match
            evnt[:start_date] = "#{event.date} #{sub.time}"

            #if evnt[:league_name] == "Formula One"
            #   #betting finishes before qualifying
            #   evnt[:start_date] = (DateTime.parse("#{event.date} #{sub.time}") + 24.hours).to_s
            #   puts evnt[:start_date]
            #end

            dt = DateTime.parse "#{event.date} #{sub.time}"
            evnt[:end_date] = (dt + duration.hours).to_s

            puts "end date #{evnt[:end_date]}"

            evnt[:home_team_first] = home_team_first
            evnt[:site] = "BetfairXML"
            evnt[:external_key] = sub.betfair_id

            #evnt[:teams][0] = evnt[:teams][0].force_encoding('UTF-8')
            #evnt[:teams][1] = evnt[:teams][1].force_encoding('UTF-8')

            create_or_update_event evnt
          end
        end
      end

    end

  end


  def motor sub,event
    #<event name="Formula 1 2013/Abu Dhabi GP" date="03/11/2013">
    if sub.title == "Points Finish"  && event.name.include?("Formula 1")
      sport_name = "Motorsport"
      league_name = "Formula One"
      name = event.name.split("/")[1]
      teams = []
      odds = [] 
      return true, sport_name, league_name, teams, 3 , true, odds, name
    else 
      return false
    end
  end

  def hockey sub,event
    #<event name="NHL 2013/14/Games 14 November/Los Angeles @ NY Islanders" date="15/11/2013">
    if sub.title == "Moneyline"
      sport_name = "Hockey"
      league_name = "NHL" if event.name.include?("NHL") 
      league_name = event.name.split(" ")[0] + event.name.split(" ")[1] if league_name.blank?

      home_team = sub.selections[0].name.split(" (")[0]
      away_team = sub.selections[1].name.split(" (")[0]

      teams = []
      home_team_id = sub.selections[0].id
      away_team_id = sub.selections[1].id
      teams << {:name=>home_team,:id=>home_team_id}
      teams << {:name=>away_team,:id=>away_team_id}

      home_match_odds = sub.selections[0].backp1
      away_match_odds = sub.selections[1].backp1
      odds = []
      odds << home_match_odds
      odds << away_match_odds

      return true, sport_name, league_name, teams, 3 , true, odds
    else
      return false
    end
  end


  def afl sub,event
    #AFL 2013/Round 19 - 03 August/Hawthorn v Richmond
    if sub.title == "Match Odds"
      sport_name = "Football - Australian"
      league_name = "AFL"
      #home_team = event.name.split("/")[2].split(" v ")[0].split(" (")[0]
      #away_team = event.name.split("/")[2].split(" v ")[1].split(" (")[0]
 
      home_team = sub.selections[0].name.split(" (")[0]
      away_team = sub.selections[1].name.split(" (")[0]

      teams = []
      home_team_id = sub.selections[0].id
      away_team_id = sub.selections[1].id
      teams << {:name=>home_team,:id=>home_team_id}
      teams << {:name=>away_team,:id=>away_team_id}

      home_match_odds = sub.selections[0].backp1
      away_match_odds = sub.selections[1].backp1
      odds = []
      odds << home_match_odds
      odds << away_match_odds

      puts home_match_odds
      puts away_match_odds

      return true, sport_name, league_name, teams, 3 , true, odds
    else 
      return false
    end
  end


  def basketball sub,event
     if sub.title == "Moneyline"
      sport_name = "Basketball"
      
      league_name = event.name.split(" 20")[0]

      home_team_first = !event.name.include?("@")

      home_team = sub.selections[0].name.split(" (")[0]
      away_team = sub.selections[1].name.split(" (")[0]

      teams = []
      home_team_id = sub.selections[0].id
      away_team_id = sub.selections[1].id
      teams << {:name=>home_team,:id=>home_team_id}
      teams << {:name=>away_team,:id=>away_team_id}

      return true, sport_name, league_name, teams, 3 , home_team_first
    else 
      return false
    end  
  end


  def mlb sub,event
    #MLB 2013/Games 27 July/HOU @ TOR
    if sub.title == "Moneyline (Listed)"
      sport_name = "Baseball"
      league_name = "Major League Baseball"
      #home_team = event.name.split("/")[2].split(" @ ")[1].split(" (")[0]
      #way_team = event.name.split("/")[2].split(" @ ")[0].split(" (")[0]

      home_team = sub.selections[0].name.split(" (")[0]
      away_team = sub.selections[1].name.split(" (")[0]

      teams = []
      home_team_id = sub.selections[0].id
      away_team_id = sub.selections[1].id
      teams << {:name=>home_team,:id=>home_team_id}
      teams << {:name=>away_team,:id=>away_team_id}

      return true, sport_name, league_name, teams, 3 , true
    else 
      return false
    end  
  end


  def cricket sub,event
    # England v Australia 2013/Test Series/England v Australia (3rd Test)
    # Sri Lanka v South Africa 2013/ODI Series/Sri Lanka v South Africa (4th ODI)
    # Zimbabwe v India 2013/ODI Series/Zimbabwe v India (3rd ODI)
    # Caribbean Premier League 2013/Fixtures 31 July/Guyana v Trinidad and Tobago
    # West Indies v Pakistan 2013/T20 Series
    # English Domestic/Friends Life T20 2013/Fixtures 28 July/Durham v Derbyshire" date="28/07/2013

    if sub.title == "Match Odds"
      sport_name = "Cricket"

       puts event.name

      if !event.name.include?("/")
        league_name = event.name
      elsif event.name.split("/")[1].include?("Fixtures")
        league_name = event.name.split("/")[0].split(" 2")[0]
      else
        league_name = event.name.split("/")[1]
      end


      #if league_name != "ODI Series" && league_name != "Test Series" && league_name != "T20 Series"
      #  league_name = event.name.split("/")[0].split(" 2")[0]
      #end

      #unless event.name.split("/")[2].include?("Fixtures")
      #  home_team = event.name.split("/")[2].split(" v ")[0].split(" (")[0]
      #  away_team = event.name.split("/")[2].split(" v ")[1].split(" (")[0]
      #else
      #  home_team = event.name.split("/")[3].split(" v ")[0].split(" (")[0]
      #  away_team = event.name.split("/")[3].split(" v ")[1].split(" (")[0]
      #end

      #<subevent title="Match Odds" date="23/08/2013" time="11:30" id="110502982" TotalAmountMatched="1491">
      #  <selection name="Zimbabwe" id="1006" backp1="4.40" backs1="5.72" backp2="4.30" backs2="40.86" backp3="2.00" backs3="170.62"/>
      #  <selection name="Pakistan" id="7461" backp1="1.16" backs1="7.33" backp2="1.15" backs2="39.00" backp3="1.14" backs3="1585.71"/>
      #</subevent>

      home_team = sub.selections[0].name.split(" (")[0]
      away_team = sub.selections[1].name.split(" (")[0]

      teams = []
      home_team_id = sub.selections[0].id
      away_team_id = sub.selections[1].id
      teams << {:name=>home_team,:id=>home_team_id}
      teams << {:name=>away_team,:id=>away_team_id}

      return true, sport_name, league_name, teams, 6 , true
    else 
      return false
    end  
  end


  def football sub,event

    # Spanish Soccer/Spanish Cup/To Qualify/Atl Madrid v Sevilla
    # English Soccer/Barclays Premier League/Fixtures 02 March    /Everton v Reading
    # German Soccer/Bundesliga 1/Fixtures 02 March    /Nurnberg v Freiburg
    # Friendlies/Fixtures 23 February /Ilves v Nokian Palloseura
    # Womens Soccer/BeNe League A/Fixtures 23 February/Standard Liege (W) v Anderlecht (W)
    # Mexican Soccer/Mexican Liga de Ascenso/Fixtures 23 February /Correcaminos UAT v Merida
    # Hong Kong Soccer/Hong Kong Division 1/Fixtures 23 February /Sun Hei v Southern District RSA
    # Turkish Soccer/Turkish A2 Ligi/Fixtures 25 February /Istanbul BBSK (Res) v Boluspor (Res)
    # Saudi Arabian Soccer/League Cup Prince Faisal bin Fahad/Fixtures 25 February /Al Ahli v Al-Hilal
    # Bahrain Soccer/Kings Cup/Fixtures 25 February /Al Ahli v Al Ittihad Bahrain
    # Italian Soccer/Serie A/Fixtures 03 March    /Bologna v Cagliari
    # English Soccer/FA Trophy/Fixtures 23 February /Gainsborough v Wrexham
    # Czech Soccer/Czech U21 League/Fixtures 25 February /FK Teplice U21 v AC Sparta Praha U21
    # Chilean Soccer/Chilean Primera B/Fixtures 25 February /Univ de Concepcion v Naval (Chile)
    # Turkish Soccer/Turkish A2 Ligi/Fixtures 25 February /Karabukspor (Res) v Genclerbirligi (Res)

    # Italian Soccer/Serie C1/A/Fixtures 24 February /San Marino Calcio v Albinoleffe

    if sub.title == "Match Odds"
      sport_name = "Football"
      #if event.name.split("/")[1].include?("Fixtures")
      #  league_name = event.name.split("/")[0].split(" 2")[0]
      #else
      league_name = event.name.split("/")[1]
      #end

      puts event.name

      if event.name.split("/")[1].include?("Fixtures")
        league_name = event.name.split("/")[0]
      end
      
      #   home_team = event.name.split("/")[2].split(" v ")[0].split(" (")[0]
      #   away_team = event.name.split("/")[2].split(" v ")[1].split(" (")[0]
      # elsif  event.name.split("/")[3].include?("Fixtures")
      #   home_team = event.name.split("/")[4].split(" v ")[0].split(" (")[0]
      #   away_team = event.name.split("/")[4].split(" v ")[1].split(" (")[0]   
      # else
      #   home_team = event.name.split("/")[3].split(" v ")[0].split(" (")[0]
      #   away_team = event.name.split("/")[3].split(" v ")[1].split(" (")[0]
      # end

      #home_team = event.name.split("/").last.split(" v ")[0].split(" (")[0]
      #away_team = event.name.split("/").last.split(" v ")[1].split(" (")[0]

      return false if sub.selections[0].blank?
      return false if sub.selections[1].blank?
      
      home_team = sub.selections[0].name.split(" (")[0]
      away_team = sub.selections[1].name.split(" (")[0]
      
      home_match_odds = sub.selections[0].backp1
      away_match_odds = sub.selections[1].backp1
      odds = []
      odds << home_match_odds
      odds << away_match_odds

      #teams = []
      #teams << home_team
      #teams << away_team

      teams = []
      home_team_id = sub.selections[0].id
      away_team_id = sub.selections[1].id
      teams << {:name=>home_team,:id=>home_team_id}
      teams << {:name=>away_team,:id=>away_team_id}

      #puts teamz  
      #puts home_match_odds
      #puts away_match_odds
      
      return true, sport_name, league_name, teams, 2 , true, odds
    else 
      return false
    end  

  end


  def gridiron sub, event
     #CFL 2013/Week 5/Games 30 July/BC @ Toronto
     #NFL Season 2013/14/Preseason Week 1/Games 08 August/Seattle @ San Diego
     if sub.title == "Moneyline"
      sport_name = "Football - American"
      league_name = league_name = event.name.split("/").first.split(" ")[0]
      #home_team = event.name.split("/").last.split(" @ ")[1].split(" (")[0]
      #away_team = event.name.split("/").last.split(" @ ")[0].split(" (")[0]

      home_team = sub.selections[1].name.split(" (")[0]
      away_team = sub.selections[0].name.split(" (")[0]

      teams = []
      home_team_id = sub.selections[0].id
      away_team_id = sub.selections[1].id
      teams << {:name=>home_team,:id=>nil}
      teams << {:name=>away_team,:id=>nil}

      return true, sport_name, league_name, teams, 3 , true
    else 
      return false
    end  

  end



  def create_or_update_event event

    sport = Sport.find_or_create_by_name(event[:sport_name])
    league = League.find_or_create_by_name_and_sport_id(event[:league_name],sport.id)

    if league.label_colour.blank?
      randy = "%06x" % (rand * 0xffffff)
      league.label_colour = "##{randy}"
      league.save
    end

    puts "For this event ... using #{league.name} #{league.sport_id}"

    event[:sport_id] = sport.id
    event[:league_id] = league.id

    external_event = ExternalEvent.where(:site=>event[:site], :external_key=>event[:external_key]).first

    if external_event.blank?

      puts "creating"
      evnt = Event.create(:sport_id=>event[:sport_id],:league_id=>event[:league_id],:start_date=>event[:start_date], :end_date=>event[:end_date], :name=>event[:name])
      ExternalEvent.create(:site=>event[:site], :external_key=>event[:external_key], :event_id=>evnt.id)

      count = 1
      event[:teams].each do |teamm|
        puts teamm[:name]

        location_type = count
        location_type = 1 if !event[:home_team_first] && count == 2
        location_type = 2 if !event[:home_team_first] && count == 1


        if teamm[:id].blank?
          team = Team.find_by_name(teamm[:name], :order=>'id desc')
          if team.blank?
            team = Team.create(:name=>teamm[:name],:sport_id=>event[:sport_id])
          end
        else
          et = ExternalTeam.where(:site=>"BetfairXML", :external_key=>teamm[:id]).first
          unless et.blank?
            team = et.team
          else
            team = Team.create(:name=>teamm[:name],:sport_id=>event[:sport_id])
            ExternalTeam.create(:site=>"BetfairXML", :external_key=>teamm[:id], :team_id=>team.id)
          end
        end

        unless event[:odds].blank?
          if event[:odds].size  == event[:teams].size
            odds = event[:odds][count-1].to_f 
            puts event[:odds].size
            #puts odds
          end
        end

        EventTeam.create(:event_id=>evnt.id,:team_id=>team.id, :location_type_id=>location_type, :match_odds=>odds)

        count = count + 1
      end

    else

      puts "updating"
      evnt = external_event.event
      evnt.update_attributes(:start_date=>event[:start_date])

      if !event[:odds].blank? && event[:odds].size == evnt.event_teams.size
        count = 0
        evnt.event_teams.each do |et|
          et.match_odds = event[:odds][count].to_f 
          puts et.match_odds
          et.save
          count +=1
        end
      end
    
    end
    
  end


end
