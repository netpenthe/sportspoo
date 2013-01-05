class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :username, :email, :password, :password_confirmation, :remember_me, :authentication_keys => [:login]

  attr_accessor :login 

  def self.find_for_database_authentication(warden_conditions)
      conditions = warden_conditions.dup
      if login = conditions.delete(:login)
        where(conditions).where(["lower(username) = :value OR lower(email) = :value", { :value => login.downcase }]).first
      else
        where(conditions).first
      end
  end

  def after_create
  end


  has_many :leagues, :class_name=>"UserPrefernce", :conditions =>"preference_type='League'"
  has_many :sports, :class_name=>"UserPrefernce", :conditions =>"preference_type='Sport'"
  has_many :teams, :class_name=>"UserPrefernce", :conditions =>"preference_type='Team'"

end
