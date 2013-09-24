class MatchOdds < ActiveRecord::Migration
  def up
    add_column :event_teams, :match_odds, :decimal
  end

  def down
    remove_column :event_teams, :match_odds
  end
end
