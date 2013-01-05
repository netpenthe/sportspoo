ActiveAdmin.register Country do

  index do
    selectable_column
    id_column
    column :name
    column :code
    default_actions
  end

  
end
