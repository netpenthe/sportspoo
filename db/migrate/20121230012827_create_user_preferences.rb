class CreateUserPreferences < ActiveRecord::Migration
  def change
    create_table :user_preferences do |t|
      t.integer :user_id
      t.string :preference_type
      t.integer :preference_id

      t.timestamps
    end
  end
end
