class FixMatchOdds < ActiveRecord::Migration
  def change 
    change_column :event_teams, :match_odds, :decimal, :precision => 12, :scale => 2
  end
end
