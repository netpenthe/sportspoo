class RenameCl2 < ActiveRecord::Migration
  def up
    rename_table :countries_leagues, :countryleagues
  end

  def down
    rename_table :countryleagues, :countries_leagues
  end
end
