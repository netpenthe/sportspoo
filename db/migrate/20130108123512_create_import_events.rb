class CreateImportEvents < ActiveRecord::Migration
  def change
    create_table :import_events do |t|
      t.text :summary
      t.datetime :dtstart
      t.datetime :dtend
      t.string :location

      t.timestamps
    end
  end
end
