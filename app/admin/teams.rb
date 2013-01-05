ActiveAdmin.register Team do

   index do
    selectable_column
    id_column
    column :name
    default_actions
  end

  
end
