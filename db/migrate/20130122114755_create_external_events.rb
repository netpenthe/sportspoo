class CreateExternalEvents < ActiveRecord::Migration
  def change
    create_table :external_events do |t|
      t.string :site
      t.integer :event_id
      t.string :external_key

      t.timestamps
    end
  end
end
