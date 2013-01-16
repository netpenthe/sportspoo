class AddSportIdToLeague < ActiveRecord::Migration
  def change
    add_column :leagues, :sport_id, :integer
  end
end
