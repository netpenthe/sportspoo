class RemoveBetfairid < ActiveRecord::Migration
  def up
    remove_column :sports,:betradar_id
    remove_column :teams, :bet_radar_id
    remove_column :teams, :betradar_id
    remove_column :leagues, :betradar_id
    remove_column :events,:betradat_event_id
  end

  def down
  end
end
