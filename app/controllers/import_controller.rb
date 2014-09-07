class ImportController < ApplicationController 

  def betfair

  	if params[:username] == BETFAIR_CONFIG['import_username'] && params[:password] == BETFAIR_CONFIG['import_password']
  	  json_response = JSON.parse params[:data]

  	  results = BetfairImport.process_response json_response

  	  render json: {:status=>"OK", :actions=>results}.to_json
  	else
  	  render json: {:status=>"Authentication Failed"}.to_json
    end

  end

end
