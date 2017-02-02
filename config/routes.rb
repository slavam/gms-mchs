Rails.application.routes.draw do
  # get 'bulletins/index'

  # get 'bulletins/create'

  # get 'bulletins/new'

  # get 'bulletins/destroy'

  # get 'bulletins/show'
  get 'bulletins/print_bulletin', to: 'bulletins#print_bulletin'
  resources :bulletins

  get 'registers/search', to: 'registers#search'
  resources :registers
  get 'synoptics/heat_show', to: 'synoptics#heat_show'
  get 'synoptics/td_show', to: 'synoptics#td_show'
  get 'synoptics/get_temps', to: 'synoptics#get_temps'
  get 'synoptics/show_by_date', to: 'synoptics#show_by_date'
  get 'synoptics/tcx1', to: 'synoptics#tcx1'
  get 'synoptics/get_tcx1_data', to: 'synoptics#get_tcx1_data'
  get 'synoptics/print_tcx1', to: 'synoptics#print_tcx1'
  get 'synoptics/update_synoptic_telegram', to: 'synoptics#update_synoptic_telegram'
  get 'synoptics/avtodor', to: 'synoptics#avtodor'
  post 'synoptics/create_synoptic_telegram', to: 'synoptics#create_synoptic_telegram'
  
  resources :synoptics
  root to: 'registers#index'
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
