class CreateLocationTypes < ActiveRecord::Migration
  def change

    create_table :location_types do |t|
      t.string :name
      t.timestamps
    end

    LocationType.create(:name=>"home")
    LocationType.create(:name=>"away")
   
  end
end
