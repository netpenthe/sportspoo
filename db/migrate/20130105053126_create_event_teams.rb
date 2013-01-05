class CreateEventTeams < ActiveRecord::Migration
  def change
    create_table :event_teams do |t|
      t.integer :event_id
      t.integer :team_id
      t.integer :location_type_id
      t.integer :location_id

      t.timestamps
    end
  end
end
