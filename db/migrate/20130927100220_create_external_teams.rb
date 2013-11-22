class CreateExternalTeams < ActiveRecord::Migration
  def change
    create_table :external_teams do |t|
      t.string :site
      t.integer :team_id
      t.string :external_key

      t.timestamps
    end
  end
end
