class AddIdCl < ActiveRecord::Migration
  def up
   add_column :country_leagues, :id, :integer
  end

  def down
   remove_column :country_leagues, :id
  end
end
