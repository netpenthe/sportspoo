class AddNameDescEvent < ActiveRecord::Migration

  def up
    add_column :events, :name, :string
    add_column :events, :description, :text
  end

  def down
    remove_column :events, :name
    remove_column :events, :description
  end

end
