class CreateImports < ActiveRecord::Migration
  def change
    create_table :imports do |t|
      t.string :league_name
      t.string :sport_name
      t.string :split_summary_on
      t.string :filter_out_summary

      t.timestamps
    end
  end
end
