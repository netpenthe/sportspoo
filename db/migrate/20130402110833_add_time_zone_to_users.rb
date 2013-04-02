class AddTimeZoneToUsers < ActiveRecord::Migration
  def change
    add_column :users, :tz, :string
  end
end
