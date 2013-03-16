ActiveAdmin.register Event do

  index do
    selectable_column
    id_column
    column :home_team
    column :away_team
    column :name
    column :start_date
    column :league
    column :sport
    column :tag_list
    default_actions
  end


  form do |f|

      f.inputs "Name" do
        f.input :name
      end

      f.inputs "Start Date" do
        f.input :start_date
      end

       f.inputs "End Date" do
        f.input :end_date
      end

       f.inputs "League" do
        f.input :league
      end

     f.inputs "Sport" do
        f.input :sport
      end

     f.inputs "Tags" do
        f.input :tag_list
      end


      f.buttons
    end

  
end
