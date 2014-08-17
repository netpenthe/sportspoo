require "net/https"
require "uri"
require 'json'

namespace :betfair do

  task :update_ng => :environment do
    aus_endpoint = "https://api-au.betfair.com/exchange/betting/rest/v1.0/"
    uk_endpoint =  "https://api.betfair.com/exchange/betting/rest/v1.0/"

    puts "doing australia"
    australia = call_betfair_api({:endpoint => aus_endpoint})
    process_response australia

    puts "doing USA"
    usa = call_betfair_api({:endpoint=>uk_endpoint, :marketCountries=>"[\"US\"]"})
    process_response usa
    
    puts "complete"
  end


  def process_response json_response
     count = 0

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
      league.gsub!("NCAAF/15","NCAA Football")

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

      create_or_update_evnt evnt
      count += 1
    end
    puts "processed #{count} events"
  end


  def login
    cert = File.read("#{Rails.root}#{BETFAIR_CONFIG['cert_file']}")
    key = File.read("#{Rails.root}#{BETFAIR_CONFIG['key_file']}")

    login_uri = URI.parse("https://identitysso.betfair.com/api/certlogin")

    http = Net::HTTP.new(login_uri.host, login_uri.port)
    http.use_ssl = true
    http.cert = OpenSSL::X509::Certificate.new(cert)
    http.key = OpenSSL::PKey::RSA.new(key)
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER

    login_request = Net::HTTP::Post.new(login_uri.request_uri)
    login_request.set_form_data({"username" => "#{BETFAIR_CONFIG['username']}", "password" => "#{BETFAIR_CONFIG['password']}"})
    login_request["Content-Type"] = "application/x-www-form-urlencoded"
    login_request["X-Application"] = "curlCommandLineTest"
    login_response = http.request(login_request)    

    json_response = JSON.parse(login_response.body)

    if json_response["loginStatus"] == "SUCCESS"
      puts "login success" 
      return json_response
    else
      raise "LOGIN FAILED"
    end

  end



  def call_betfair_api options
    # do the options
    endpoint = options[:endpoint]
    action = options[:action] || "listMarketCatalogue"
    market_countries = options[:marketCountries] || "[\"\"]"

    # login
    json_response = login
    session_token = json_response["sessionToken"]
    app_key = BETFAIR_CONFIG['app_key']

    #setup the request
    uri = URI.parse("#{endpoint}#{action}/")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    request = Net::HTTP::Post.new(uri.request_uri)
    request["Accept"] = "application/json"
    request["Content-Type"] = "application/json"
    request["X-Application"] = "#{app_key}"
    request["X-Authentication"] = "#{session_token}"
    request.body = "{\"filter\":{\"marketTypeCodes\":[\"MATCH_ODDS\"], \"marketCountries\":#{market_countries}}, \"maxResults\":1000, \"marketProjection\":[\"EVENT\", \"COMPETITION\",\"EVENT_TYPE\"]}"

    #do the request
    response = http.request(request)

    #json_response = '[{"marketId":"2.101006827","marketName":"Match Odds","totalMatched":175.47874399999998,"eventType":{"id":"1","name":"Soccer"},"competition":{"id":"5463025","name":"FFA Cup 2014"},"event":{"id":"27242730","name":"Sydney United 58 v Far North Queensland","countryCode":"AU","timezone":"Australia/Sydney","openDate":"2014-08-12T09:30:00.000Z"}},{"marketId":"2.101006749","marketName":"Match Odds","totalMatched":560.198864,"eventType":{"id":"1","name":"Soccer"},"competition":{"id":"5463025","name":"FFA Cup 2014"},"event":{"id":"27242728","name":"Blacktown City v Bentleigh Greens","countryCode":"AU","timezone":"Australia/Sydney","openDate":"2014-08-12T09:30:00.000Z"}},{"marketId":"2.101006788","marketName":"Match Odds","totalMatched":8818.948005,"eventType":{"id":"1","name":"Soccer"},"competition":{"id":"5463025","name":"FFA Cup 2014"},"event":{"id":"27242729","name":"Melbourne City v Sydney","countryCode":"AU","timezone":"Australia/Sydney","openDate":"2014-08-12T09:30:00.000Z"}},{"marketId":"2.101008995","marketName":"Match Odds","totalMatched":3065.226764,"eventType":{"id":"1","name":"Soccer"},"competition":{"id":"5463025","name":"FFA Cup 2014"},"event":{"id":"27242731","name":"Adelaide City v Western Sydney","countryCode":"AU","timezone":"Australia/Adelaide","openDate":"2014-08-12T10:00:00.000Z"}},{"marketId":"2.100973981","marketName":"Match Odds","totalMatched":0.0,"eventType":{"id":"4","name":"Cricket"},"competition":{"id":"5812036","name":"Australia A v South Africa A 2014"},"event":{"id":"27214842","name":"Australia A v South Africa A","countryCode":"AU","timezone":"Australia/Queensland","openDate":"2014-08-13T23:30:00.000Z"}},{"marketId":"2.101010970","marketName":"Match Odds","totalMatched":0.0,"eventType":{"id":"5","name":"Rugby Union"},"competition":{"id":"5698271","name":"ITM Cup 2014"},"event":{"id":"27246217","name":"Taranaki v Counties Manukau","countryCode":"NZ","timezone":"NZ","openDate":"2014-08-14T07:35:00.000Z"}},{"marketId":"2.101007533","marketName":"Match Odds","totalMatched":940.7711069999999,"eventType":{"id":"1477","name":"Rugby League"},"competition":{"id":"3985280","name":"NRL 2014"},"event":{"id":"27243123","name":"Rabbitohs v Broncos","countryCode":"AU","timezone":"Australia/Sydney","openDate":"2014-08-14T09:45:00.000Z"}},{"marketId":"2.101010978","marketName":"Match Odds","totalMatched":0.0,"eventType":{"id":"5","name":"Rugby Union"},"competition":{"id":"5698271","name":"ITM Cup 2014"},"event":{"id":"27246219","name":"Southland v Bay Of Plenty","countryCode":"NZ","timezone":"NZ","openDate":"2014-08-15T07:35:00.000Z"}},{"marketId":"2.101007572","marketName":"Match Odds","totalMatched":893.1882559999999,"eventType":{"id":"1477","name":"Rugby League"},"competition":{"id":"3985280","name":"NRL 2014"},"event":{"id":"27243125","name":"Eels v Bulldogs","countryCode":"AU","timezone":"Australia/Sydney","openDate":"2014-08-15T09:45:00.000Z"}},{"marketId":"2.101004240","marketName":"Match Odds","totalMatched":3995.4198789999996,"eventType":{"id":"61420","name":"Australian Rules"},"competition":{"id":"3879057","name":"AFL 2014"},"event":{"id":"27239865","name":"Carlton v Geelong","countryCode":"AU","timezone":"Australia/Sydney","openDate":"2014-08-15T09:50:00.000Z"}},{"marketId":"2.101010986","marketName":"Match Odds","totalMatched":0.0,"eventType":{"id":"5","name":"Rugby Union"},"competition":{"id":"5698271","name":"ITM Cup 2014"},"event":{"id":"27246221","name":"Otago v North Harbour","countryCode":"NZ","timezone":"NZ","openDate":"2014-08-16T02:35:00.000Z"}},{"marketId":"2.101004278","marketName":"Match Odds","totalMatched":3923.0403309999992,"eventType":{"id":"61420","name":"Australian Rules"},"competition":{"id":"3879057","name":"AFL 2014"},"event":{"id":"27239867","name":"Sydney v St Kilda","countryCode":"AU","timezone":"Australia/Sydney","openDate":"2014-08-16T03:45:00.000Z"}},{"marketId":"2.101004316","marketName":"Match Odds","totalMatched":778.5691919999999,"eventType":{"id":"61420","name":"Australian Rules"},"competition":{"id":"3879057","name":"AFL 2014"},"event":{"id":"27239868","name":"Gold Coast v Port Adelaide","countryCode":"AU","timezone":"Australia/Queensland","openDate":"2014-08-16T04:10:00.000Z"}},{"marketId":"2.101010994","marketName":"Match Odds","totalMatched":0.0,"eventType":{"id":"5","name":"Rugby Union"},"competition":{"id":"5698271","name":"ITM Cup 2014"},"event":{"id":"27246222","name":"Canterbury v Auckland","countryCode":"NZ","timezone":"NZ","openDate":"2014-08-16T04:35:00.000Z"}},{"marketId":"2.101007611","marketName":"Match Odds","totalMatched":44.050816,"eventType":{"id":"1477","name":"Rugby League"},"competition":{"id":"3985280","name":"NRL 2014"},"event":{"id":"27243128","name":"Raiders v Dragons","countryCode":"AU","timezone":"Australia/Sydney","openDate":"2014-08-16T05:00:00.000Z"}},{"marketId":"2.101011002","marketName":"Match Odds","totalMatched":0.0,"eventType":{"id":"5","name":"Rugby Union"},"competition":{"id":"5698271","name":"ITM Cup 2014"},"event":{"id":"27246223","name":"Wellington v Waikato","countryCode":"NZ","timezone":"NZ","openDate":"2014-08-16T06:35:00.000Z"}},{"marketId":"2.101004354","marketName":"Match Odds","totalMatched":767.194228,"eventType":{"id":"61420","name":"Australian Rules"},"competition":{"id":"3879057","name":"AFL 2014"},"event":{"id":"27239869","name":"Essendon v West Coast","countryCode":"AU","timezone":"Australia/Sydney","openDate":"2014-08-16T06:40:00.000Z"}},{"marketId":"2.101007650","marketName":"Match Odds","totalMatched":0.0,"eventType":{"id":"1477","name":"Rugby League"},"competition":{"id":"3985280","name":"NRL 2014"},"event":{"id":"27243129","name":"Storm v Sharks","countryCode":"AU","timezone":"Australia/Sydney","openDate":"2014-08-16T07:30:00.000Z"}},{"marketId":"2.101007689","marketName":"Match Odds","totalMatched":44.050816,"eventType":{"id":"1477","name":"Rugby League"},"competition":{"id":"3985280","name":"NRL 2014"},"event":{"id":"27243132","name":"Tigers v Roosters","countryCode":"AU","timezone":"Australia/Sydney","openDate":"2014-08-16T09:30:00.000Z"}},{"marketId":"2.101004392","marketName":"Match Odds","totalMatched":3104.8217820000004,"eventType":{"id":"61420","name":"Australian Rules"},"competition":{"id":"3879057","name":"AFL 2014"},"event":{"id":"27239870","name":"Collingwood v Brisbane","countryCode":"AU","timezone":"Australia/Sydney","openDate":"2014-08-16T09:40:00.000Z"}},{"marketId":"2.101004430","marketName":"Match Odds","totalMatched":1227.33688,"eventType":{"id":"61420","name":"Australian Rules"},"competition":{"id":"3879057","name":"AFL 2014"},"event":{"id":"27239871","name":"Adelaide v Richmond","countryCode":"AU","timezone":"Australia/Adelaide","openDate":"2014-08-16T09:40:00.000Z"}},{"marketId":"2.101000217","marketName":"Match Odds","totalMatched":7707.3169689999995,"eventType":{"id":"5","name":"Rugby Union"},"competition":{"id":"4795473","name":"The Rugby Championship 2014"},"event":{"id":"27236166","name":"Australia v New Zealand","countryCode":"AU","timezone":"Australia/Sydney","openDate":"2014-08-16T10:05:00.000Z"}},{"marketId":"2.101000239","marketName":"Match Odds NO DRAW","totalMatched":0.0,"eventType":{"id":"5","name":"Rugby Union"},"competition":{"id":"4795473","name":"The Rugby Championship 2014"},"event":{"id":"27236166","name":"Australia v New Zealand","countryCode":"AU","timezone":"Australia/Sydney","openDate":"2014-08-16T10:05:00.000Z"}},{"marketId":"2.101000250","marketName":"Match Odds","totalMatched":0.0,"eventType":{"id":"5","name":"Rugby Union"},"competition":{"id":"4795473","name":"The Rugby Championship 2014"},"event":{"id":"27236167","name":"South Africa v Argentina","countryCode":"ZA","timezone":"Africa/Johannesburg","openDate":"2014-08-16T15:05:00.000Z"}},{"marketId":"2.101000272","marketName":"Match Odds NO DRAW","totalMatched":0.0,"eventType":{"id":"5","name":"Rugby Union"},"competition":{"id":"4795473","name":"The Rugby Championship 2014"},"event":{"id":"27236167","name":"South Africa v Argentina","countryCode":"ZA","timezone":"Africa/Johannesburg","openDate":"2014-08-16T15:05:00.000Z"}},{"marketId":"2.101011010","marketName":"Match Odds","totalMatched":0.0,"eventType":{"id":"5","name":"Rugby Union"},"competition":{"id":"5698271","name":"ITM Cup 2014"},"event":{"id":"27246225","name":"Tasman v Hawkes Bay","countryCode":"NZ","timezone":"NZ","openDate":"2014-08-17T02:35:00.000Z"}},{"marketId":"2.101005325","marketName":"Match Odds","totalMatched":284.174857,"eventType":{"id":"61420","name":"Australian Rules"},"competition":{"id":"3879057","name":"AFL 2014"},"event":{"id":"27240778","name":"North Melbourne v Western Bulldogs","countryCode":"AU","timezone":"Australia/Sydney","openDate":"2014-08-17T03:10:00.000Z"}},{"marketId":"2.101007728","marketName":"Match Odds","totalMatched":0.0,"eventType":{"id":"1477","name":"Rugby League"},"competition":{"id":"3985280","name":"NRL 2014"},"event":{"id":"27243134","name":"Knights v Warriors","countryCode":"AU","timezone":"Australia/Sydney","openDate":"2014-08-17T04:00:00.000Z"}},{"marketId":"2.101011018","marketName":"Match Odds","totalMatched":0.0,"eventType":{"id":"5","name":"Rugby Union"},"competition":{"id":"5698271","name":"ITM Cup 2014"},"event":{"id":"27246226","name":"Northland v Manawatu","countryCode":"NZ","timezone":"NZ","openDate":"2014-08-17T04:35:00.000Z"}},{"marketId":"2.101007767","marketName":"Match Odds","totalMatched":0.0,"eventType":{"id":"1477","name":"Rugby League"},"competition":{"id":"3985280","name":"NRL 2014"},"event":{"id":"27243135","name":"Titans v Sea Eagles","countryCode":"AU","timezone":"Australia/Queensland","openDate":"2014-08-17T05:00:00.000Z"}},{"marketId":"2.101005387","marketName":"Match Odds","totalMatched":143.201378,"eventType":{"id":"61420","name":"Australian Rules"},"competition":{"id":"3879057","name":"AFL 2014"},"event":{"id":"27240780","name":"Melbourne v GWS","countryCode":"AU","timezone":"Australia/Sydney","openDate":"2014-08-17T05:20:00.000Z"}},{"marketId":"2.101005425","marketName":"Match Odds","totalMatched":2147.259924,"eventType":{"id":"61420","name":"Australian Rules"},"competition":{"id":"3879057","name":"AFL 2014"},"event":{"id":"27240782","name":"Fremantle v Hawthorn","countryCode":"AU","timezone":"Australia/Perth","openDate":"2014-08-17T06:40:00.000Z"}},{"marketId":"2.101007806","marketName":"Match Odds","totalMatched":214.928858,"eventType":{"id":"1477","name":"Rugby League"},"competition":{"id":"3985280","name":"NRL 2014"},"event":{"id":"27243138","name":"Panthers v Cowboys","countryCode":"AU","timezone":"Australia/Sydney","openDate":"2014-08-18T09:00:00.000Z"}},{"marketId":"2.101012711","marketName":"Match Odds","totalMatched":0.0,"eventType":{"id":"1","name":"Soccer"},"competition":{"id":"5463025","name":"FFA Cup 2014"},"event":{"id":"27247333","name":"Hakoah Sydney City East v Palm Beach Sharks","countryCode":"AU","timezone":"Australia/Sydney","openDate":"2014-08-19T09:30:00.000Z"}},{"marketId":"2.101012750","marketName":"Match Odds","totalMatched":0.0,"eventType":{"id":"1","name":"Soccer"},"competition":{"id":"5463025","name":"FFA Cup 2014"},"event":{"id":"27247334","name":"Stirling Lions v Brisbane","countryCode":"AU","timezone":"Australia/Perth","openDate":"2014-08-19T11:30:00.000Z"}}]'
    return JSON.parse response.body
  end



  def create_or_update_evnt event

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
      puts "creating event with -> sport: '#{sport.name}' league: '#{league.name}' teams: '#{event[:teams].to_s}'"

      evnt = Event.create(:sport_id=>event[:sport_id],:league_id=>event[:league_id],:start_date=>event[:start_date], :end_date=>event[:end_date], :name=>event[:name])
      ExternalEvent.create(:site=>event[:site], :external_key=>event[:external_key], :event_id=>evnt.id)

      count = 1
      event[:teams].each do |teamm|
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

        EventTeam.create(:event_id=>evnt.id,:team_id=>team.id, :location_type_id=>location_type)

        count = count + 1
      end

    else
      evnt = external_event.event
      evnt.update_attributes(:start_date=>event[:start_date])
      puts "updating event #{evnt.id} with -> sport: '#{sport.name}' league: '#{league.name}' teams: '#{event[:teams].to_s}'"    
    end
    
  end






end



#procedure:
# grab all Australian match odds events
# grab all UK
# grab all USA


#listEvents:
#  {"event":{"id":"27243856","name":"MIN @ HOU","countryCode":"US","timezone":"US/Eastern","openDate":"2014-08-13T00:10:00.000Z"}

#listCompetitions:
#  {"competition":{"id":"334719","name":"German Super Cup"}

#listEventTypes:
#  {"eventType":{"id":"1","name":"Soccer"}
#  AU: [{"eventType":{"id":"1","name":"Soccer"},"marketCount":28},{"eventType":{"id":"2","name":"Tennis"},"marketCount":2},{"eventType":{"id":"1477","name":"Rugby League"},"marketCount":124},{"eventType":{"id":"61420","name":"Australian Rules"},"marketCount":157},{"eventType":{"id":"6231","name":"Financial Bets"},"marketCount":1},{"eventType":{"id":"2378961","name":"Politics"},"marketCount":3},{"eventType":{"id":"4","name":"Cricket"},"marketCount":3},{"eventType":{"id":"5","name":"Rugby Union"},"marketCount":60},{"eventType":{"id":"7","name":"Horse Racing"},"marketCount":133},{"eventType":{"id":"8","name":"Motor Sport"},"marketCount":1},{"eventType":{"id":"10","name":"Special Bets"},"marketCount":2},{"eventType":{"id":"4339","name":"Greyhound Racing"},"marketCount":10}]
#  UK: [{"eventType":{"id":"1","name":"Soccer"},"marketCount":20981},{"eventType":{"id":"2","name":"Tennis"},"marketCount":737},{"eventType":{"id":"3","name":"Golf"},"marketCount":15},{"eventType":{"id":"4","name":"Cricket"},"marketCount":307},{"eventType":{"id":"5","name":"Rugby Union"},"marketCount":28},{"eventType":{"id":"6","name":"Boxing"},"marketCount":13},{"eventType":{"id":"7","name":"Horse Racing"},"marketCount":302},{"eventType":{"id":"8","name":"Motor Sport"},"marketCount":42},{"eventType":{"id":"7524","name":"Ice Hockey"},"marketCount":145},{"eventType":{"id":"10","name":"Special Bets"},"marketCount":19},{"eventType":{"id":"11","name":"Cycling"},"marketCount":6},{"eventType":{"id":"7522","name":"Basketball"},"marketCount":77},{"eventType":{"id":"1477","name":"Rugby League"},"marketCount":48},{"eventType":{"id":"4339","name":"Greyhound Racing"},"marketCount":187},{"eventType":{"id":"6231","name":"Financial Bets"},"marketCount":48},{"eventType":{"id":"2378961","name":"Politics"},"marketCount":23},{"eventType":{"id":"998918","name":"Bowls"},"marketCount":56},{"eventType":{"id":"26420387","name":"Mixed Martial Arts"},"marketCount":44},{"eventType":{"id":"3503","name":"Darts"},"marketCount":2},{"eventType":{"id":"72382","name":"Pool"},"marketCount":1},{"eventType":{"id":"3988","name":"Athletics"},"marketCount":40},{"eventType":{"id":"2152880","name":"Gaelic Games"},"marketCount":12},{"eventType":{"id":"6422","name":"Snooker"},"marketCount":33},{"eventType":{"id":"6423","name":"American Football"},"marketCount":20},{"eventType":{"id":"315220","name":"Poker"},"marketCount":7},{"eventType":{"id":"7511","name":"Baseball"},"marketCount":106}]





