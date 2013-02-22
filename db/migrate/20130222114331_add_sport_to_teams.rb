class AddSportToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :sport_id, :integer
  end
end
