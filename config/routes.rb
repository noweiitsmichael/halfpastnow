Myapp::Application.routes.draw do
  


  get "mobile/new"

  resources :histories

  resources :bookmarks

  resources :channels

  get "info/about"

  get "info/contact"

  devise_for :users, :controllers => {:registrations => "registrations", :omniauth_callbacks => "omniauth_callbacks"}

  get "tag/index"

  # resources :events
  # resources :venues
  # resources :feedbacks
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

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
  authenticated :user do
    root :to => 'events#index'
  end
  
  root :to => 'events#index'

  # See how all your routes lay out with "rake routes"

  # TODO: overcome the stupidity that is rails 3 routing and clean this up.
  match 'venues' => 'venues#index'
  match 'events' => 'events#index'
  match 'tags' => 'tags#index'
  match 'info' => 'info#about'
  match 'admin' => 'admin#index'
  match 'admin/venues' => 'venues#index'
  match 'admin/artists' => 'acts#index'

  match 'feedbacks' => 'feedbacks#index'
  match 'users' => 'users#index', :as => "user"
  match '/search' => 'events#search'

  match '/auth/:provider/callback' => 'authentications#create'

  match ':controller(/:action(/:id(.:format)))'
end
