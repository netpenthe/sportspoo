class AddColourLeagueLabels < ActiveRecord::Migration
  def up
    add_column :leagues,:label_colour, :string
  end

  def down
    remove_column :leagues,:label_colour
  end
end
