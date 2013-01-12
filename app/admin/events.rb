ActiveAdmin.register Event do

  index do
    selectable_column
    id_column
    column :home_team
    column :away_team
    column :name
    column :start_date
    column :league
    column :sport
    default_actions
  end
  
end
