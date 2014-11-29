class BetfairImport


	def self.process_response json_response
    count = 0
    results = []

    json_response.each do |event|
      sport = event["eventType"]["name"]
      sport.gsub!("Soccer","Football")
      sport.gsub!("Australian Rules","Football - Australian")

      if event["competition"].blank?
        league = "Other"
      else
        league = event["competition"]["name"].gsub(" 2014","")
      end

      league.gsub!("NFL Season/15","NFL")
      #league.gsub!("NCAAF/15","NCAA Football")
      #league.gsub!("A League/15","A-League")
      #league.gsub!("Australian NBL/15","Australian NBL")
      #league.gsub!("NBA/15","NBA")
      #league.gsub!("NHL/15","NHL")
      #league.gsub!("Australia v India/15","Australia v India")
      league = league.split("/")[0]

      event_name = event["event"]["name"].split(" (Game")[0]
      start_time = event["event"]["openDate"]

      evnt = {}

      if event_name.include?(" v ")
        evnt[:teams] = event_name.split(" v ").map{|t| {:name=>t.strip, :id=>nil} } 
        evnt[:home_team_first] = true
      else
        evnt[:teams] = event_name.split(" @ ").map{|t| {:name=>t.strip, :id=>nil} } 
        evnt[:home_team_first] = false
      end

      evnt[:sport_name]  = sport
      evnt[:league_name] = league
      evnt[:site] = "BetfairNG"
      evnt[:external_key] = event["event"]["id"]
      evnt[:start_date] = DateTime.parse start_time
      evnt[:end_date] = evnt[:start_date] + 2.hours

      results << BetfairImport.create_or_update_evnt(evnt)
      count += 1
    end
    
    return results
  end



  def self.create_or_update_evnt event
    results = ""
    sport = Sport.find_or_create_by_name(event[:sport_name])
    league = League.find_or_create_by_name_and_sport_id(event[:league_name],sport.id)

    if league.label_colour.blank?
      randy = "%06x" % (rand * 0xffffff)
      league.label_colour = "##{randy}"
      league.save
    end

    event[:sport_id] = sport.id
    event[:league_id] = league.id

    external_event = ExternalEvent.where(:site=>event[:site], :external_key=>event[:external_key]).first

    if external_event.blank?
      #puts "creating event with -> sport: '#{sport.name}' league: '#{league.name}' teams: '#{event[:teams].to_s}'"
      results = {:action=>"create", :sport=>"#{sport.name}", :league=>"#{league.name}", :teams=>event[:teams]}      
      evnt = Event.create(:sport_id=>event[:sport_id],:league_id=>event[:league_id],:start_date=>event[:start_date], :end_date=>event[:end_date], :name=>event[:name])
      ExternalEvent.create(:site=>event[:site], :external_key=>event[:external_key], :event_id=>evnt.id)

      count = 1
      event[:teams].each do |teamm|
        location_type = count
        location_type = 1 if !event[:home_team_first] && count == 2
        location_type = 2 if !event[:home_team_first] && count == 1

        if teamm[:id].blank?
          team = Team.find_by_name_and_sport_id(teamm[:name], sport.id, :order=>'id desc')
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

        EventTeam.create(:event_id=>evnt.id,:team_id=>team.id, :location_type_id=>location_type)

        count = count + 1
      end

    else
      evnt = external_event.event
      evnt.update_attributes(:start_date=>event[:start_date])
      #puts "updating event #{evnt.id} with -> sport: '#{sport.name}' league: '#{league.name}' teams: '#{event[:teams].to_s}'"
      results = {:action=>"update", :event=>"#{evnt.id}", :sport=>"#{sport.name}", :league=>"#{league.name}", :teams=>event[:teams]} 
    end

    return results
    
  end


end
