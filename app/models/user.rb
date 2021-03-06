class User < ActiveRecord::Base

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,:omniauthable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :username, :email, :password, :password_confirmation, :remember_me, :authentication_keys => [:login]

  attr_accessor :login 

  after_create :setup_preferences

  #facebook
  attr_accessible :provider, :uid
  has_many :user_preferences


  def setup_preferences
    puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ setting up preferences..."
  end


  def tz
     read_attribute(:tz) || 'Pacific Time (US & Canada)'
  end
  

  def self.find_for_database_authentication(warden_conditions)
      conditions = warden_conditions.dup
      if login = conditions.delete(:login)
        where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
      else
        where(conditions).first
      end
  end

  def self.find_for_facebook_oauth(auth, signed_in_resource=nil)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first
    unless user
      user = User.create(name:auth.extra.raw_info.name,
                         provider:auth.provider,
                         uid:auth.uid,
                         email:auth.info.email,
                         password:Devise.friendly_token[0,20]
                         )
    end
    user
  end

  

  def self.find_for_twitter_oauth(auth, signed_in_resource=nil)
    user = User.where(:provider => auth.provider, :uid => auth.uid).first
    unless user
      user = User.create(name:"",
                         provider:auth.provider,
                         uid:auth.uid,
                         email:auth.info.email,
                         password:Devise.friendly_token[0,20]
                         )
    end
    user
  end
  
  def self.new_with_session(params, session)
    super.tap do |user|
      if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
        user.email = data["email"] if user.email.blank?
      end
    end
  end

  def my_leagues
    League.find(:all, :conditions=>["id in (?)", self.leagues.map{|l| l.preference_id}])
  end

  def my_teams
    Team.find(:all, :conditions=>["id in (?)", self.teams.map{|l| l.preference_id}])
  end

  def after_create
  end

  def teams_ordered
   Team.find(:all, :conditions=>['id in (?)', self.teams.map{|t| t.preference_id}]) 
  end

  def addInitialLeagues(leagues)
    leagues.each do |foo| 
      UserPreference.find_or_create_by_user_id_and_preference_type_and_preference_id(self.id,"League",foo.to_s)
    end
  end

  def addInitialTeams(teams)
    teams.each do |foo| 
      puts "team user_id.... "+self.id.to_s
      puts "team team_id.... "+foo.to_s
      UserPreference.find_or_create_by_user_id_and_preference_type_and_preference_id(self.id,"Team",foo.to_s)
    end
  end

  has_many :leagues, :class_name=>"UserPreference", :conditions =>"preference_type='League'"
  has_many :sports, :class_name=>"UserPreference", :conditions =>"preference_type='Sport'"
  has_many :teams, :class_name=>"UserPreference", :conditions =>"preference_type='Team'"

  def self.upcoming_events(user, limit)
    Event.find(:all, :conditions=>['start_date > ? and start_date < ? and (league_id = ? OR sport_id = ? OR team_id = ?)',Time.now,Time.now+7.days,[user.leagues.map{|l|l.preference_id}.join(",")], [user.sports.map{|l|l.preference_id}.join(",")],[user.teams.map{|l|l.preference_id}.join(",")]],:order=>:start_date,:joins=>"left join event_teams on event_teams.team_id = events.id",:limit=>limit, :include=>[:event_teams, :teams])
  end

   # Event.find(:all, :conditions=>['start_date > ? and (league_id = ? OR sport_id = ? OR team_id = ?',Time.now,[user.leagues.map{|l|l.preference_id}.join(",")], [user.sports.map{|l|l.preference_id}.join(",")],[user.teams.map{|l|l.preference_id}.join(",")]],:order=>:start_date,:include=>:event_teams)
end
