class CacheController < ApplicationController


  def clear_country_events
   cache_dir = ActionController::Base.page_cache_directory
   puts cache_dir
   FileUtils.rm_r(Dir.glob(cache_dir+"/country/events/*")) rescue Errno::ENOENT
   render :text => "OK"
 end


 def clear_country_leagues
   cache_dir = ActionController::Base.page_cache_directory
   puts cache_dir
   FileUtils.rm_r(Dir.glob(cache_dir+"/country/leagues/*")) rescue Errno::ENOENT
   render :text => "OK"
 end


 def clear_user
   expire_fragment("menu.teams.user.#{params[:user_id]}")
   expire_fragment("events.user.#{params[:user_id]}")
   expire_fragment("teams.user.#{params[:user_id]}")
   render :text => "OK"
 end

end
