class UserPreference < ActiveRecord::Base
  validates_uniqueness_of :user_id, :scope => [:preference_type,:preference_id], :message=>"You already follow this!"
  validates_presence_of :preference_type, :user_id, :preference_id
  belongs_to :user


  def name
     up = Kernel.const_get(self.preference_type)
     result = up.find self.preference_id
     result.name
  end

end
