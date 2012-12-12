class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.string :name
      t.integer :bet_radar_id
      t.timestamps
    end
  end
end
