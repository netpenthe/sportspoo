class RenameCl < ActiveRecord::Migration
  def up
   rename_table :country_leagues, :countries_leagues
  end

  def down
    rename_table :countries_leagues, :country_leagues
  end
end
