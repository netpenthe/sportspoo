class AddImportId < ActiveRecord::Migration
  def up
    add_column :events, :import_id, :integer
    add_column :sports, :import_id, :integer
    add_column :leagues, :import_id, :integer
  end

  def down
    remove_column :events, :import_id
    remove_column :sports, :import_id
    remove_column :leagues, :import_id
  end
end
