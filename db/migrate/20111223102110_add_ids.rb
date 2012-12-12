class AddIds < ActiveRecord::Migration
  def up
    add_column :leagues, :betradar_id, :integer
    add_column :sports, :betradar_id, :integer
    add_column :teams, :betradar_id, :integer
  end

  def down
  end
end
