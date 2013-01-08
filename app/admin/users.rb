ActiveAdmin.register User do

 index do
    selectable_column
    id_column
    column :email
    column :username
    column :last_sign_in_at
    column :last_sign_in_ip
    column :created_at
    column :provider
    column :uid
    
    default_actions
  end

  
end
