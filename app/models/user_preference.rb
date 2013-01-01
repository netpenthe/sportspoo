class UserPreference < ActiveRecord::Base


  def name
     up = Kernel.const_get(self.preference_type)
     result = up.find self.id
     result.name
  end


end
