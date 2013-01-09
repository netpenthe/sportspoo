class AddHomeTeamFirst < ActiveRecord::Migration
  def up
    add_column :imports,:home_team_first, :boolean, :default=>true
  end

  def down
    remove_column :imports,:home_team_first
  end
  
end
