class FixLocations < ActiveRecord::Migration
  
  def up
    remove_column :event_teams, :location_id
    add_column :events, :location_id, :integer
  end

  
  def down
    add_column :event_teams, :location_id, :integer
    remove_column :events, :location_id
  end

end
