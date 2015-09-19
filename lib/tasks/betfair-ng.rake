require "net/https"
require "uri"
require 'json'


namespace :betfair do


  task :update_ng_via_api => :environment do
    puts "updating via API" 

    aus_endpoint = "https://api-au.betfair.com/exchange/betting/rest/v1.0/"
    uk_endpoint =  "https://api.betfair.com/exchange/betting/rest/v1.0/"

    puts "doing UK mugby"
    uk_football = call_betfair_api({:endpoint=>uk_endpoint, :marketCountries=>"[\"GB\"]", :eventTypeIds=>"[5]"})
    post_data uk_football
    sleep 30

    puts "\ndoing australia"
    australia = call_betfair_api({:endpoint => aus_endpoint})
    puts "found #{australia.count} aus events"
    post_data australia
    sleep 10 

    puts "\ndoing USA"
    usa = call_betfair_api({:endpoint=>uk_endpoint, :marketCountries=>"[\"US\"]"})
    puts "found #{usa.count} usa events"
    post_data usa
    sleep 10
    
    puts "\ndoing UK football"
    uk_football = call_betfair_api({:endpoint=>uk_endpoint, :marketCountries=>"[\"GB\"]", :eventTypeIds=>"[1]"})
    puts "found #{uk_football.count} uk football events"
    post_data uk_football
    sleep 10

    puts "\ndoing DE football"
    uk_football = call_betfair_api({:endpoint=>uk_endpoint, :marketCountries=>"[\"DE\"]", :eventTypeIds=>"[1]"})
    puts "found #{uk_football.count} DE football events"
    post_data uk_football
    sleep 10

    puts "\ndoing ES football"
    uk_football = call_betfair_api({:endpoint=>uk_endpoint, :marketCountries=>"[\"ES\"]", :eventTypeIds=>"[1]"})
    puts "found #{uk_football.count} es football events"
    post_data uk_football
    sleep 10

    puts "\ndoing cricket"
    cricket = call_betfair_api({:endpoint=>uk_endpoint, :eventTypeIds=>"[4]"})
    puts "found #{cricket.count} cricket events"
    post_data cricket
      
    puts "\ncompleted betfair import via API"
  end


  task :update_ng => :environment do
    aus_endpoint = "https://api-au.betfair.com/exchange/betting/rest/v1.0/"
    uk_endpoint =  "https://api.betfair.com/exchange/betting/rest/v1.0/"


    puts "doing australia"
    australia = call_betfair_api({:endpoint => aus_endpoint})
    BetfairImport.process_response australia
    sleep 30

    puts "doing USA"
    usa = call_betfair_api({:endpoint=>uk_endpoint, :marketCountries=>"[\"US\"]"})
    BetfairImport.process_response usa
    sleep 30
    
    puts "doing UK football"
    uk_football = call_betfair_api({:endpoint=>uk_endpoint, :marketCountries=>"[\"GB\"]", :eventTypeIds=>"[1]"})
    BetfairImport.process_response uk_football
    sleep 30

    puts "doing cricket"
    cricket = call_betfair_api({:endpoint=>uk_endpoint, :eventTypeIds=>"[4]"})
    BetfairImport.process_response cricket
      
    puts "complete"
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
      puts login_response.body
      raise "LOGIN FAILED"
    end
  end


  def call_betfair_api options
    # do the options
    endpoint = options[:endpoint]
    action = options[:action] || "listMarketCatalogue"
    market_countries = options[:marketCountries] || "[\"\"]"
    event_type_ids = options[:eventTypeIds] || "[]"

    # login
    json_response = login
    session_token = json_response["sessionToken"]
    app_key = BETFAIR_CONFIG['app_key']

    #setup the request
    uri = URI.parse("#{endpoint}#{action}/")

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_PEER
    http.ssl_version = :TLSv1

    request = Net::HTTP::Post.new(uri.request_uri)
    request["Accept"] = "application/json"
    request["Content-Type"] = "application/json"
    request["X-Application"] = "#{app_key}"
    request["X-Authentication"] = "#{session_token}"
    request.body = "{\"filter\":{\"marketTypeCodes\":[\"MATCH_ODDS\"], \"marketCountries\":#{market_countries},\"eventTypeIds\":#{event_type_ids}}, \"maxResults\":1000, \"marketProjection\":[\"EVENT\", \"COMPETITION\",\"EVENT_TYPE\"]}"

    #do the request
    response = http.request(request)

    #json_response = '[{"marketId":"2.101006827","marketName":"Match Odds","totalMatched":175.47874399999998,"eventType":{"id":"1","name":"Soccer"},"competition":{"id":"5463025","name":"FFA Cup 2014"},"event":{"id":"27242730","name":"Sydney United 58 v Far North Queensland","countryCode":"AU","timezone":"Australia/Sydney","openDate":"2014-08-12T09:30:00.000Z"}},{"marketId":"2.101006749","marketName":"Match Odds","totalMatched":560.198864,"eventType":{"id":"1","name":"Soccer"},"competition":{"id":"5463025","name":"FFA Cup 2014"},"event":{"id":"27242728","name":"Blacktown City v Bentleigh Greens","countryCode":"AU","timezone":"Australia/Sydney","openDate":"2014-08-12T09:30:00.000Z"}},{"marketId":"2.101006788","marketName":"Match Odds","totalMatched":8818.948005,"eventType":{"id":"1","name":"Soccer"},"competition":{"id":"5463025","name":"FFA Cup 2014"},"event":{"id":"27242729","name":"Melbourne City v Sydney","countryCode":"AU","timezone":"Australia/Sydney","openDate":"2014-08-12T09:30:00.000Z"}},{"marketId":"2.101008995","marketName":"Match Odds","totalMatched":3065.226764,"eventType":{"id":"1","name":"Soccer"},"competition":{"id":"5463025","name":"FFA Cup 2014"},"event":{"id":"27242731","name":"Adelaide City v Western Sydney","countryCode":"AU","timezone":"Australia/Adelaide","openDate":"2014-08-12T10:00:00.000Z"}},{"marketId":"2.100973981","marketName":"Match Odds","totalMatched":0.0,"eventType":{"id":"4","name":"Cricket"},"competition":{"id":"5812036","name":"Australia A v South Africa A 2014"},"event":{"id":"27214842","name":"Australia A v South Africa A","countryCode":"AU","timezone":"Australia/Queensland","openDate":"2014-08-13T23:30:00.000Z"}},{"marketId":"2.101010970","marketName":"Match Odds","totalMatched":0.0,"eventType":{"id":"5","name":"Rugby Union"},"competition":{"id":"5698271","name":"ITM Cup 2014"},"event":{"id":"27246217","name":"Taranaki v Counties Manukau","countryCode":"NZ","timezone":"NZ","openDate":"2014-08-14T07:35:00.000Z"}},{"marketId":"2.101007533","marketName":"Match Odds","totalMatched":940.7711069999999,"eventType":{"id":"1477","name":"Rugby League"},"competition":{"id":"3985280","name":"NRL 2014"},"event":{"id":"27243123","name":"Rabbitohs v Broncos","countryCode":"AU","timezone":"Australia/Sydney","openDate":"2014-08-14T09:45:00.000Z"}},{"marketId":"2.101010978","marketName":"Match Odds","totalMatched":0.0,"eventType":{"id":"5","name":"Rugby Union"},"competition":{"id":"5698271","name":"ITM Cup 2014"},"event":{"id":"27246219","name":"Southland v Bay Of Plenty","countryCode":"NZ","timezone":"NZ","openDate":"2014-08-15T07:35:00.000Z"}},{"marketId":"2.101007572","marketName":"Match Odds","totalMatched":893.1882559999999,"eventType":{"id":"1477","name":"Rugby League"},"competition":{"id":"3985280","name":"NRL 2014"},"event":{"id":"27243125","name":"Eels v Bulldogs","countryCode":"AU","timezone":"Australia/Sydney","openDate":"2014-08-15T09:45:00.000Z"}},{"marketId":"2.101004240","marketName":"Match Odds","totalMatched":3995.4198789999996,"eventType":{"id":"61420","name":"Australian Rules"},"competition":{"id":"3879057","name":"AFL 2014"},"event":{"id":"27239865","name":"Carlton v Geelong","countryCode":"AU","timezone":"Australia/Sydney","openDate":"2014-08-15T09:50:00.000Z"}},{"marketId":"2.101010986","marketName":"Match Odds","totalMatched":0.0,"eventType":{"id":"5","name":"Rugby Union"},"competition":{"id":"5698271","name":"ITM Cup 2014"},"event":{"id":"27246221","name":"Otago v North Harbour","countryCode":"NZ","timezone":"NZ","openDate":"2014-08-16T02:35:00.000Z"}},{"marketId":"2.101004278","marketName":"Match Odds","totalMatched":3923.0403309999992,"eventType":{"id":"61420","name":"Australian Rules"},"competition":{"id":"3879057","name":"AFL 2014"},"event":{"id":"27239867","name":"Sydney v St Kilda","countryCode":"AU","timezone":"Australia/Sydney","openDate":"2014-08-16T03:45:00.000Z"}},{"marketId":"2.101004316","marketName":"Match Odds","totalMatched":778.5691919999999,"eventType":{"id":"61420","name":"Australian Rules"},"competition":{"id":"3879057","name":"AFL 2014"},"event":{"id":"27239868","name":"Gold Coast v Port Adelaide","countryCode":"AU","timezone":"Australia/Queensland","openDate":"2014-08-16T04:10:00.000Z"}},{"marketId":"2.101010994","marketName":"Match Odds","totalMatched":0.0,"eventType":{"id":"5","name":"Rugby Union"},"competition":{"id":"5698271","name":"ITM Cup 2014"},"event":{"id":"27246222","name":"Canterbury v Auckland","countryCode":"NZ","timezone":"NZ","openDate":"2014-08-16T04:35:00.000Z"}},{"marketId":"2.101007611","marketName":"Match Odds","totalMatched":44.050816,"eventType":{"id":"1477","name":"Rugby League"},"competition":{"id":"3985280","name":"NRL 2014"},"event":{"id":"27243128","name":"Raiders v Dragons","countryCode":"AU","timezone":"Australia/Sydney","openDate":"2014-08-16T05:00:00.000Z"}},{"marketId":"2.101011002","marketName":"Match Odds","totalMatched":0.0,"eventType":{"id":"5","name":"Rugby Union"},"competition":{"id":"5698271","name":"ITM Cup 2014"},"event":{"id":"27246223","name":"Wellington v Waikato","countryCode":"NZ","timezone":"NZ","openDate":"2014-08-16T06:35:00.000Z"}},{"marketId":"2.101004354","marketName":"Match Odds","totalMatched":767.194228,"eventType":{"id":"61420","name":"Australian Rules"},"competition":{"id":"3879057","name":"AFL 2014"},"event":{"id":"27239869","name":"Essendon v West Coast","countryCode":"AU","timezone":"Australia/Sydney","openDate":"2014-08-16T06:40:00.000Z"}},{"marketId":"2.101007650","marketName":"Match Odds","totalMatched":0.0,"eventType":{"id":"1477","name":"Rugby League"},"competition":{"id":"3985280","name":"NRL 2014"},"event":{"id":"27243129","name":"Storm v Sharks","countryCode":"AU","timezone":"Australia/Sydney","openDate":"2014-08-16T07:30:00.000Z"}},{"marketId":"2.101007689","marketName":"Match Odds","totalMatched":44.050816,"eventType":{"id":"1477","name":"Rugby League"},"competition":{"id":"3985280","name":"NRL 2014"},"event":{"id":"27243132","name":"Tigers v Roosters","countryCode":"AU","timezone":"Australia/Sydney","openDate":"2014-08-16T09:30:00.000Z"}},{"marketId":"2.101004392","marketName":"Match Odds","totalMatched":3104.8217820000004,"eventType":{"id":"61420","name":"Australian Rules"},"competition":{"id":"3879057","name":"AFL 2014"},"event":{"id":"27239870","name":"Collingwood v Brisbane","countryCode":"AU","timezone":"Australia/Sydney","openDate":"2014-08-16T09:40:00.000Z"}},{"marketId":"2.101004430","marketName":"Match Odds","totalMatched":1227.33688,"eventType":{"id":"61420","name":"Australian Rules"},"competition":{"id":"3879057","name":"AFL 2014"},"event":{"id":"27239871","name":"Adelaide v Richmond","countryCode":"AU","timezone":"Australia/Adelaide","openDate":"2014-08-16T09:40:00.000Z"}},{"marketId":"2.101000217","marketName":"Match Odds","totalMatched":7707.3169689999995,"eventType":{"id":"5","name":"Rugby Union"},"competition":{"id":"4795473","name":"The Rugby Championship 2014"},"event":{"id":"27236166","name":"Australia v New Zealand","countryCode":"AU","timezone":"Australia/Sydney","openDate":"2014-08-16T10:05:00.000Z"}},{"marketId":"2.101000239","marketName":"Match Odds NO DRAW","totalMatched":0.0,"eventType":{"id":"5","name":"Rugby Union"},"competition":{"id":"4795473","name":"The Rugby Championship 2014"},"event":{"id":"27236166","name":"Australia v New Zealand","countryCode":"AU","timezone":"Australia/Sydney","openDate":"2014-08-16T10:05:00.000Z"}},{"marketId":"2.101000250","marketName":"Match Odds","totalMatched":0.0,"eventType":{"id":"5","name":"Rugby Union"},"competition":{"id":"4795473","name":"The Rugby Championship 2014"},"event":{"id":"27236167","name":"South Africa v Argentina","countryCode":"ZA","timezone":"Africa/Johannesburg","openDate":"2014-08-16T15:05:00.000Z"}},{"marketId":"2.101000272","marketName":"Match Odds NO DRAW","totalMatched":0.0,"eventType":{"id":"5","name":"Rugby Union"},"competition":{"id":"4795473","name":"The Rugby Championship 2014"},"event":{"id":"27236167","name":"South Africa v Argentina","countryCode":"ZA","timezone":"Africa/Johannesburg","openDate":"2014-08-16T15:05:00.000Z"}},{"marketId":"2.101011010","marketName":"Match Odds","totalMatched":0.0,"eventType":{"id":"5","name":"Rugby Union"},"competition":{"id":"5698271","name":"ITM Cup 2014"},"event":{"id":"27246225","name":"Tasman v Hawkes Bay","countryCode":"NZ","timezone":"NZ","openDate":"2014-08-17T02:35:00.000Z"}},{"marketId":"2.101005325","marketName":"Match Odds","totalMatched":284.174857,"eventType":{"id":"61420","name":"Australian Rules"},"competition":{"id":"3879057","name":"AFL 2014"},"event":{"id":"27240778","name":"North Melbourne v Western Bulldogs","countryCode":"AU","timezone":"Australia/Sydney","openDate":"2014-08-17T03:10:00.000Z"}},{"marketId":"2.101007728","marketName":"Match Odds","totalMatched":0.0,"eventType":{"id":"1477","name":"Rugby League"},"competition":{"id":"3985280","name":"NRL 2014"},"event":{"id":"27243134","name":"Knights v Warriors","countryCode":"AU","timezone":"Australia/Sydney","openDate":"2014-08-17T04:00:00.000Z"}},{"marketId":"2.101011018","marketName":"Match Odds","totalMatched":0.0,"eventType":{"id":"5","name":"Rugby Union"},"competition":{"id":"5698271","name":"ITM Cup 2014"},"event":{"id":"27246226","name":"Northland v Manawatu","countryCode":"NZ","timezone":"NZ","openDate":"2014-08-17T04:35:00.000Z"}},{"marketId":"2.101007767","marketName":"Match Odds","totalMatched":0.0,"eventType":{"id":"1477","name":"Rugby League"},"competition":{"id":"3985280","name":"NRL 2014"},"event":{"id":"27243135","name":"Titans v Sea Eagles","countryCode":"AU","timezone":"Australia/Queensland","openDate":"2014-08-17T05:00:00.000Z"}},{"marketId":"2.101005387","marketName":"Match Odds","totalMatched":143.201378,"eventType":{"id":"61420","name":"Australian Rules"},"competition":{"id":"3879057","name":"AFL 2014"},"event":{"id":"27240780","name":"Melbourne v GWS","countryCode":"AU","timezone":"Australia/Sydney","openDate":"2014-08-17T05:20:00.000Z"}},{"marketId":"2.101005425","marketName":"Match Odds","totalMatched":2147.259924,"eventType":{"id":"61420","name":"Australian Rules"},"competition":{"id":"3879057","name":"AFL 2014"},"event":{"id":"27240782","name":"Fremantle v Hawthorn","countryCode":"AU","timezone":"Australia/Perth","openDate":"2014-08-17T06:40:00.000Z"}},{"marketId":"2.101007806","marketName":"Match Odds","totalMatched":214.928858,"eventType":{"id":"1477","name":"Rugby League"},"competition":{"id":"3985280","name":"NRL 2014"},"event":{"id":"27243138","name":"Panthers v Cowboys","countryCode":"AU","timezone":"Australia/Sydney","openDate":"2014-08-18T09:00:00.000Z"}},{"marketId":"2.101012711","marketName":"Match Odds","totalMatched":0.0,"eventType":{"id":"1","name":"Soccer"},"competition":{"id":"5463025","name":"FFA Cup 2014"},"event":{"id":"27247333","name":"Hakoah Sydney City East v Palm Beach Sharks","countryCode":"AU","timezone":"Australia/Sydney","openDate":"2014-08-19T09:30:00.000Z"}},{"marketId":"2.101012750","marketName":"Match Odds","totalMatched":0.0,"eventType":{"id":"1","name":"Soccer"},"competition":{"id":"5463025","name":"FFA Cup 2014"},"event":{"id":"27247334","name":"Stirling Lions v Brisbane","countryCode":"AU","timezone":"Australia/Perth","openDate":"2014-08-19T11:30:00.000Z"}}]'
    return JSON.parse response.body
  end


  def post_data json_response
    uri = URI.parse(BETFAIR_CONFIG['import_api_host'])
    http = Net::HTTP.new(uri.host, uri.port)
    response = http.post('/import/betfair', URI.encode_www_form({
            :data => json_response.to_json, 
            :username=>BETFAIR_CONFIG['import_username'], 
            :password=>BETFAIR_CONFIG['import_password']}))
    puts response.body
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





