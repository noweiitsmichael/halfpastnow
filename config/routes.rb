Myapp::Application.routes.draw do

  resources :unofficialacl do
    collection do
      post :search
      get :show_event
    end
  end

  get "mobile/new"

  resources :histories
  resources :friendships

  resources :venues do 
    collection do 
      get 'find'
    end 
  end

  resources :bookmark_lists

  match 'bookmarks/custom_create' => 'bookmarks#custom_create'
  match 'bookmarks/attending_create' => 'bookmarks#attending_create'
  match 'bookmarks/add_to_featuredlist' => 'bookmarks#add_to_featuredlist'
  match 'bookmarks/update_comment' => 'bookmarks#update_comment'
  match 'bookmarks/destroyBookmarkedList' => 'bookmarks#destroyBookmarkedList'

  resources :bookmarks

  get "info/about"
  get "info/contact"
  get "info/privacy"
  get "info/terms"
  get "info/contest_rules"

  devise_for :users, :controllers => {:registrations => "registrations", :omniauth_callbacks => "omniauth_callbacks"}
  get "tag/index"

  # namespace :admin do
  #   resources :venues, :acts
  # end


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

  #root :to => 'events#new_splash'
  #root :to => 'unofficialacl#index'

  root :to => 'unofficialacl#index', :conditions => { :host => "www.unofficialacl.com" }
  # map.connect "", :controller => "unofficialacl", :conditions => { :host => "www.unofficialacl.com" }

  # See how all your routes lay out with "rake routes"

  # TODO: overcome the stupidity that is rails 3 routing and clean this up.
  # match 'venues' => 'venues#index'
  # match 'events' => 'events#index'
  match 'tags' => 'tags#index'
  match 'info' => 'info#about'
  match 'admin' => 'admin#index'
  match 'admin/venues' => 'venues#index'
  match 'admin/artists' => 'acts#index'
  match 'admin/bookmark_lists' => 'bookmark_lists#index'
  match 'venues/new_event' => 'venues#new_event'
  match 'feedbacks' => 'feedbacks#index'
  match 'users' => 'users#index', :as => "user"
  match 'users/friends' => 'users#friends'
  match '/search' => 'events#index'
  match '/sxsw' => 'events#sxsw'
  match '/unofficialacl' => 'unofficialacl#index'

  match '/auth/:provider/callback' => 'authentications#create'

  match ':controller(/:action(/:id(.:format)))'
end
