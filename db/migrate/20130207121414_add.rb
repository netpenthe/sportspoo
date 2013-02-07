class Add < ActiveRecord::Migration
  def up
    add_column :countryleagues, :priority, :integer
  end

  def down
    remove_column :countryleagues, :priority
  end
end
