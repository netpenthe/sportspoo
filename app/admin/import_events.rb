ActiveAdmin.register ImportEvent do

  index do
    selectable_column
    id_column
    column :summary
    column :dtstart
    column :dtend
    column :location

    default_actions
  end

  
end
