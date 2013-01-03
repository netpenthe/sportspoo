class CreateCountryLeagues < ActiveRecord::Migration
  def change
    create_table :country_leagues, :id=>false do |t|
      t.integer :country_id
      t.integer :league_id
    end
  end
end
