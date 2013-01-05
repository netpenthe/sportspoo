ActiveAdmin.register Countryleague do

  index do
    selectable_column
    column :country
    column :league
    default_actions
  end

  
end
