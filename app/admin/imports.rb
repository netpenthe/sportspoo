ActiveAdmin.register Import do

   #form :partial => "admin/form"

   form do |f|
      f.inputs "Details" do
        f.input :league_name
        f.input :sport_name
        f.input :ics, :as=>:file
      end
      f.buttons
   end

   show do
      render "import"
   end
  
end
