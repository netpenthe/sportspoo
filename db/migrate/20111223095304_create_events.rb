class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.integer :sport_id
      t.integer :league_id
      t.integer :betradat_event_id
      t.integer :home_team_id
      t.integer :away_team_id
      t.datetime :start_date

      t.timestamps
    end
  end
end
