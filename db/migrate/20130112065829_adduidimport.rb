class Adduidimport < ActiveRecord::Migration
  
  def up
    add_column :import_events, :uid, :string
  end

  def down
    remove_column :import_events, :uid
  end
  
end
