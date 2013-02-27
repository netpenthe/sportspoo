ActiveAdmin.register Team do

   index do
    selectable_column
    id_column
    column :name
    column :shortname_list
    column :nickname_list
    default_actions
   end

   form do |f|

      f.inputs "Details" do
        f.input :name
      end

      f.inputs "Nicknames" do
        f.input :nickname_list
      end

      f.inputs "Short Name" do
        f.input :shortname_list
      end

      f.buttons
    end
  
end
