ActiveAdmin.register League do

  index do
    selectable_column
    id_column
    column "name" do |league|
    	raw "<span class='label' style='padding:1px 4px 2px;font-size:10px;-webkit-border-radius:3px;color:white;background-color:#{league.label_colour}'>#{league.name}</span>"
    end
    default_actions
  end

  
end
