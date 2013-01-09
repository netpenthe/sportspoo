class AddImportIdTeam < ActiveRecord::Migration
  def up
    add_column :teams, :import_id, :integer
  end

  def down
    remove_column :teams, :import_id
  end
end
