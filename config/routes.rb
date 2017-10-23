Rails.application.routes.draw do
  post 'sea_observations/create_sea_telegram', to: 'sea_observations#create_sea_telegram'
  resources :sea_observations
  post 'storm_observations/create_storm_telegram', to: 'storm_observations#create_storm_telegram'
  resources :storm_observations
  post 'agro_observations/create_agro_telegram', to: 'agro_observations#create_agro_telegram'
  resources :agro_observations
  post 'synoptic_observations/create_synoptic_telegram', to: 'synoptic_observations#create_synoptic_telegram'
  put 'synoptic_observations/update_synoptic_telegram', to: 'synoptic_observations#update_synoptic_telegram'
  get '/search_synoptic_telegrams', to: 'synoptic_observations#search_synoptic_telegrams'
  get 'synoptic_observations/synoptic_storm_telegrams', to: 'synoptic_observations#synoptic_storm_telegrams'
  get 'synoptic_observations/heat_donbass_show', to: 'synoptic_observations#heat_donbass_show'
  get 'synoptic_observations/get_temps', to: 'synoptic_observations#get_temps'
  get '/input_telegrams', to: 'synoptic_observations#input_telegrams'
  resources :synoptic_observations
  delete 'pollution_values/delete_value/:id', to: 'pollution_values#delete_value'
  resources :pollution_values
  get 'measurements/weather_update', to: 'measurements#weather_update'
  post 'measurements/save_pollutions', to: 'measurements#save_pollutions'
  post 'measurements/create_or_update', to: 'measurements#create_or_update'
  get 'measurements/get_convert_params', to: 'measurements#get_convert_params'
  get 'measurements/chem_forma2', to: 'measurements#chem_forma2'
  get 'measurements/chem_forma1_tza', to: 'measurements#chem_forma1_tza'
  get 'measurements/get_chem_forma1_tza_data', to: 'measurements#get_chem_forma1_tza_data'
  get 'measurements/print_forma1_tza', to: 'measurements#print_forma1_tza'
  get 'measurements/get_chem_forma2_data', to: 'measurements#get_chem_forma2_data'
  get 'measurements/print_forma2', to: 'measurements#print_forma2'
  post 'measurements/convert_akiam', to: 'measurements#convert_akiam'
  resources :measurements
  resources :materials
  resources :posts
  resources :cities
  resources :stations
  resources :audits
  resources :concentrations
  get 'pollutions/index', to: 'pollutions#index'
  get 'pollutions/chem_forma1', to: 'pollutions#chem_forma1'
  get 'pollutions/get_chem_forma1_data', to: 'pollutions#get_chem_forma1_data'
  get 'pollutions/background_concentration', to: 'pollutions#background_concentration'
  get 'pollutions/get_chem_bc_data', to: 'pollutions#get_chem_bc_data'

  resources :substances
#  get 'substances/edit', to: 'substances#edit'

#  get 'substances/update'

#  get 'substances/index', to: 'substances#index'

#  get 'substances/show'

  get 'sessions/new'

  # get 'bulletins/index'

  # get 'bulletins/create'

  # get 'bulletins/new'

  # get 'bulletins/destroy'

  # get 'bulletins/show'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  resources :users
  get 'bulletins/print_bulletin', to: 'bulletins#print_bulletin'
  get 'bulletins/new_sea_bulletin', to: 'bulletins#new_sea_bulletin'
  get 'bulletins/new_radiation_bulletin', to: 'bulletins#new_radiation_bulletin'
  # get 'bulletins/:id/sea_show', to: 'bulletins#sea_show'
  get 'bulletins/new_storm_bulletin', to: 'bulletins#new_storm_bulletin'
  # get 'bulletins/:id/storm_show', to: 'bulletins#storm_show'
  get 'bulletins/new_holiday_bulletin', to: 'bulletins#new_holiday_bulletin'
  # get 'bulletins/:id/holiday_show', to: 'bulletins#holiday_show'
  get 'bulletins/:id/bulletin_show', to: 'bulletins#bulletin_show'
  get 'bulletins/list', to: 'bulletins#list'
  # post 'bulletins/sea_bulletin_create', to: 'bulletins#sea_bulletin_create'
  resources :bulletins

  get 'registers/search', to: 'registers#search'
  resources :registers
  
  get 'synoptics/list', to: 'synoptics#list'
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
  get '/make_web_query', to: 'synoptics#make_web_query'
  post '/make_web_query', to: 'synoptics#search_in_web'
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
