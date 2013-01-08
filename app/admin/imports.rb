ActiveAdmin.register Import do

   #form :partial => "admin/form"

  index do
    selectable_column
    id_column
    column :sport_name
    column :league_name
    column :ics_file_name
    column :import_events_count
    default_actions
    column "Sync" do |import|
      link_to "Load", load_admin_import_path(import), :method=>:put
    end
  end

   form do |f|
      f.inputs "Details" do
        f.input :league_name
        f.input :sport_name
        f.input :ics, :as=>:file
        f.input :split_summary_on
        f.input :filter_out_summary
      end
      f.buttons
   end

   show do
      render "import"
   end

   member_action :load, :method => :put do
     import = Import.find params[:id]

     ImportEvent.delete_all ["import_id = ?",import.id]

     File.open(import.ics.path, "r") do |file_handle|
       components = RiCal.parse(file_handle)
       components.each do |component|
         component.events.each do |evnt|
            ImportEvent.create(:summary => evnt.summary, :dtstart=> evnt.dtstart, :dtend=> evnt.dtend, :location=>evnt.location, :import_id => import.id)
         end
       end     
     end
     redirect_to :back
   end

end
