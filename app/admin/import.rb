ActiveAdmin.register_page "Import" do
    content do
      form(:html => { :multipart => true }) do |f|
        f.input :ics, :as => :file
        f.input :approved
        f.button
      end
    end
end
