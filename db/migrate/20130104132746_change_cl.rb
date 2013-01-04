class ChangeCl < ActiveRecord::Migration
  def up

   drop_table :countryleagues
   
    create_table "countryleagues", :force => true do |t|
      t.integer "country_id"
      t.integer "league_id"
    end

  end

  def down
  end
end
