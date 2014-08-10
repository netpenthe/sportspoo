require "net/https"
require "uri"
require 'json'

namespace :betfair do

  task :update_ng => :environment do

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

    puts "login success" if json_response["loginStatus"] == "SUCCESS"
    puts 

    session_token = json_response["sessionToken"]
    app_key = BETFAIR_CONFIG['app_key']

    endpoint = "https://api.betfair.com/exchange/betting/rest/v1.0/"

    uri = URI.parse("#{endpoint}listEvents/")
    bhttp = Net::HTTP.new(uri.host, uri.port)
    bhttp.use_ssl = true
    bhttp.verify_mode = OpenSSL::SSL::VERIFY_PEER

    request = Net::HTTP::Post.new(uri.request_uri)
    request["Accept"] = "application/json"
    request["Content-Type"] = "application/json"
    request["X-Application"] = "#{app_key}"
    request["X-Authentication"] = "#{session_token}"
    request.body = "{\"filter\":{\"competitionIds\":[\"7\"]}}"
    response = bhttp.request(request)

    puts response.body
    puts response.code
  end

end