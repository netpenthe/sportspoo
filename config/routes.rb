Sportspoo::Application.routes.draw do
  
  ActiveAdmin.routes(self)

  devise_for :admin_users, ActiveAdmin::Devise.config
  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks" , :registrations => "users/registrations" }
  devise_scope :user do match '/users/auth/twitter_email' => "users/omniauth_callbacks#twitter_email" end

  resources :user_preferences
  resources :sports
  resources :imports

  match '/' => 'front#index'
  match '/config' => 'user_preferences#index', :as=>:config
  match '/list' => 'front#list', :as=>:list
  match '/u/:username' => 'front#list'
  match '/u/:username/chat' => 'front#chat'

  match '/country/leagues/:country' => 'countries#leagues' 
  match '/country/events/:country' => 'countries#events' 

  match '/front/user_events(/:num_events)' => 'front#user_events' 
  match '/front/user_events_by_team/:team_id(/:num_events)' => 'front#user_events_by_team' 
  match '/front/moar_events' => 'front#moar_events' 

  match '/leagues/all' => 'leagues#all' 
  match '/leagues/country/:country' => 'leagues#country' 
  match '/leagues/events/:league_id' => 'leagues#events' 
  match '/leagues/:username' => 'leagues#username' 

  match 'l/:name' => 'leagues#name'

  match '/search/results' => 'front#search'

  match '/front/get_tz_offset/:tz' => 'front#get_tz_offset'
  match '/user_preference/remove_league/:league_id' => 'user_preferences#remove_league'
  match '/user_preference/remove_team/:team_id' => 'user_preferences#remove_team'
  match '/user/save_tz/:tz' => 'user_preferences#save_tz'
  match '/front/save_session' => 'front#save_session'

  
  match '/cache/clear/user/:user_id' => 'cache#clear_user'
  match '/cache/clear/country/events' => 'cache#clear_country_events'
  match '/cache/clear/country/leagues' => 'cache#clear_country_leagues'

  

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  root :to => 'front#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
