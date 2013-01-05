class Remove < ActiveRecord::Migration
  def up
   remove_column :events, :home_team_id
   remove_column :events, :away_team_id
  end

  def down
   add_column :events, :home_team_id, :integer
   add_column :events, :away_team_id, :integer
  end
end
