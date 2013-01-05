ActiveAdmin.register Import do

   #form :partial => "admin/form"

  index do
    selectable_column
    id_column
    column :sport_name
    column :league_name
    column :ics_file_name
    default_actions
  end

   form do |f|
      f.inputs "Details" do
        f.input :league_name
        f.input :sport_name
        f.input :ics, :as=>:file
        f.input :split_summary_on
      end
      f.buttons
   end

   show do
      render "import"
   end
  
end
