class CreateTeamNames < ActiveRecord::Migration
  
  def change
    create_table :team_names do |t|
      t.string :name
      t.string :type
      t.integer :team_id

      t.timestamps
    end
  end

end
