class ImportController < ApplicationController 

  def betfair

  	if params[:username] == BETFAIR_CONFIG['import_username'] && params[:password] == BETFAIR_CONFIG['import_password']
  	  json_response = JSON.parse params[:data]

  	  BetfairImport.process_response json_response
  	  render json: "OK"
  	else
  	  render json: "Authentication Failed"
    end

  end

end
