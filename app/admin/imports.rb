ActiveAdmin.register Import do

   #form :partial => "admin/form"

  index do
    selectable_column
    id_column
    column :sport_name
    column :league_name
    column :ics_file_name
    column "tmp events", :import_events_count
    column "events", :imported_events_count
    column "sports", :imported_sports_count
    column "leagues", :imported_leagues_count
    column "teams", :imported_teams_count
    default_actions
    
    column "Draft" do |import|
      link_to "Load", load_admin_import_path(import), :method=>:put
    end
    column "Do it" do |import|
      link_to "Import", import_admin_import_path(import), :method=>:put
    end
  end

   form do |f|
      f.inputs "Details" do
        f.input :league_name
        f.input :sport_name
        f.input :ics, :as=>:file
        f.input :split_summary_on
        f.input :filter_out_summary
        f.input :home_team_first
      end
      f.buttons
   end

   show do
      render "import"
   end

   member_action :load, :method => :put do
     import = Import.find params[:id]

     ImportEvent.delete_all ["import_id = ?",import.id]

     File.open(import.ics.path, "r:ISO-8859-1") do |file_handle|
       components = RiCal.parse(file_handle)
       puts components.count
       components.each do |component|
         component.events.each do |evnt|
            ImportEvent.create(:summary => evnt.summary, :dtstart=> evnt.dtstart, :dtend=> evnt.dtend, :location=>evnt.location, :import_id => import.id, :uid=>evnt.uid)
         end
       end     
     end
     redirect_to :back
   end


   member_action :import, :method => :put do
      import = Import.find params[:id]
      
      sport = Sport.find_by_name import.sport_name.rstrip
      sport = Sport.create(:name=>import.sport_name.rstrip, :import_id=>import.id) if sport.blank?
      
      league = League.find_by_name import.league_name.rstrip
      league = League.create(:name=>import.league_name.rstrip, :import_id=>import.id, :sport_id=>sport.id) if league.blank?

      import.import_events.each do |ie|

        #stop duplicates
        if ie.event.blank?

          unless import.split_summary_on.blank?
            home_team = Team.find_for_sport ie.home_team, sport.id
            home_team = Team.create(:import_id=>import.id, :name=>ie.home_team,:sport_id=>sport.id) if home_team.blank?
            away_team = Team.find_for_sport ie.away_team, sport.id
            away_team = Team.create(:import_id=>import.id, :name=>ie.away_team,:sport_id=>sport.id) if away_team.blank?
          else
            event = Event.create(:import_id=>import.id, :import_event_id=>ie.id ,:start_date=>ie.dtstart,:end_date=>ie.dtend,
                                 :sport_id=>sport.id, :league_id=>league.id, :name=>ie.summary)
          end

          unless home_team.blank? || away_team.blank? || sport.blank? || league.blank?

            event = Event.create(:import_id=>import.id, :import_event_id=>ie.id ,:start_date=>ie.dtstart,:end_date=>ie.dtend, :sport_id=>sport.id, :league_id=>league.id)
            
            eventteam = EventTeam.create :event_id=>event.id, :team_id=>home_team.id, :location_type_id=>1
            eventteam = EventTeam.create :event_id=>event.id, :team_id=>away_team.id, :location_type_id=>2
            
            ExternalEvent.create(:event_id=>event.id, :site=>"iCal", :external_key=>ie.uid) unless ie.uid.blank?

            unless ie.location.blank?
              location = Location.find_by_name ie.location
              location = Location.create(:name=>ie.location) if location.blank?
              event.location_id = location.id
              event.save
            end

          end

        end

      end

      redirect_to :back

   end


end
