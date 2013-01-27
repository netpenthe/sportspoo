ActiveAdmin.register EventTeam do

  index do
    selectable_column
    id_column
    column "event_id"
    column "team_id"
    column :event
    column :team
    default_actions
  end
  
end
