class AdduidimportEventId < ActiveRecord::Migration
  def up
    add_column :events, :import_event_id, :integer
  end

  def down
    remnove_column :events, :import_event_id
  end
  
end
