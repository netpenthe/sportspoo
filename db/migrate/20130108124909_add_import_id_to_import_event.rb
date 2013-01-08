class AddImportIdToImportEvent < ActiveRecord::Migration
  def change
    add_column :import_events, :import_id, :integer
  end
end
