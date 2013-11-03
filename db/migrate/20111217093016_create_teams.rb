class CreateTeams < ActiveRecord::Migration
	
  def change
    create_table :teams do |t|
      t.string :name
      t.integer :bet_radar_id
      t.timestamps
    end

    #CREATE INDEX idx_event_teams_id ON event_teams(event_id);
    add_index :event_teams, :event_id
  end

end
