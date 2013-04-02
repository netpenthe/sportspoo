class UserPreferencesController < ApplicationController
  # GET /user_preferences
  # GET /user_preferences.json
  def index
    
    @user_preferences = current_user.user_preferences.order("preference_type")
    @leagues = League.order("name").all
    @sports = Sport.order("name").all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @user_preferences }
    end
  end

  # GET /user_preferences/1
  # GET /user_preferences/1.json
#  def show
#    @user_preference = UserPreference.find(params[:id])
#
#    respond_to do |format|
#      format.html # show.html.erb
#      format.json { render json: @user_preference }
#    end
#  end

  # GET /user_preferences/new
  # GET /user_preferences/new.json
  def new
    @user_preference = UserPreference.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user_preference }
    end
  end

  # GET /user_preferences/1/edit
#  def edit
#    @user_preference = UserPreference.find(params[:id])
#  end

  # POST /user_preferences
  # POST /user_preferences.json
  def create
    @user_preference = UserPreference.new(params[:user_preference])
    @user_preference.user_id = current_user.id

    respond_to do |format|
      if @user_preference.save
        format.html { redirect_to user_preferences_url, notice: 'User preference was successfully created.' }
        format.json { render json: @user_preference, status: :created, location: @user_preference }
      else
        format.html { render action: "new" }
        format.json { render json: @user_preference.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /user_preferences/1
  # PUT /user_preferences/1.json
#  def update
#    @user_preference = UserPreference.find(params[:id])
#
#    respond_to do |format|
#      if @user_preference.update_attributes(params[:user_preference])
#        format.html { redirect_to user_preferences_url, notice: 'User preference was successfully updated.' }
#        format.json { head :ok }
#      else
#        format.html { render action: "edit" }
#        format.json { render json: @user_preference.errors, status: :unprocessable_entity }
#      end
#    end
#  end

  # DELETE /user_preferences/1
  # DELETE /user_preferences/1.json
  def destroy
    @user_preference = UserPreference.find(params[:id])
    @user_preference.destroy if @user_preference.user_id == current_user.id

    respond_to do |format|
      format.html { redirect_to user_preferences_url }
      format.json { head :ok }
    end
  end

  def remove_team
    if current_user
      UserPreference.delete_all(['user_id = ? and preference_id = ? and preference_type = "Team"',current_user.id, params[:team_id]])
      respond_to do |format|
        format.json { head :ok }
      end
    end
  end
  def remove_league
    if current_user
      UserPreference.delete_all(['user_id = ? and preference_id = ? and preference_type = "League"',current_user.id, params[:league_id]])
      respond_to do |format|
        format.json { head :ok }
      end
    else 
      respond_to do |format|
        format.json { head :ok }
      end
    end
  end
  def save_tz
    if current_user && params[:tz]
      current_user.update_attribute(:tz,params[:tz])
    end
    respond_to do |format|
      format.text {render :text => 'ok'}
    end
  end
end
