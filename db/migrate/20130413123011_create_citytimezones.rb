class CreateCitytimezones < ActiveRecord::Migration
  def change
    create_table :citytimezones do |t|
      t.string :city
      t.string :tz_detail
      t.string :tz
      t.string :tz_dropdown
      t.string :country
      t.float :latitude
      t.float :longitude

      t.timestamps
    end
  end
end
