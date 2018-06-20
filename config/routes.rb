Rails.application.routes.draw do
  post 'applicants/to_buffer', to: 'applicants#to_buffer'
  resources :applicants
  get 'agro_dec_observations/search_agro_dec_telegrams', to: 'agro_dec_observations#search_agro_dec_telegrams'
  post 'agro_dec_observations/create_agro_dec_telegram', to: 'agro_dec_observations#create_agro_dec_telegram'
  get 'agro_dec_observations/get_last_telegrams', to: 'agro_dec_observations#get_last_telegrams'
  get 'agro_dec_observations/input_agro_dec_telegrams', to: 'agro_dec_observations#input_agro_dec_telegrams'
  put 'agro_dec_observations/update_agro_dec_telegram', to: 'agro_dec_observations#update_agro_dec_telegram'
  resources :agro_dec_observations
  resources :agro_works
  resources :agro_damages
  resources :agro_phases
  resources :agro_crops
  resources :agro_crop_categories
  resources :agro_phase_categories
  resources :meteo_links
  resources :chem_coefficients
  resources :laboratories
  post 'sea_observations/create_sea_telegram', to: 'sea_observations#create_sea_telegram'
  get 'sea_observations/get_last_telegrams', to: 'sea_observations#get_last_telegrams'
  get 'sea_observations/input_sea_telegrams', to: 'sea_observations#input_sea_telegrams'
  put 'sea_observations/update_sea_telegram', to: 'sea_observations#update_sea_telegram'
  resources :sea_observations
  get 'storm_observations/search_storm_telegrams', to: 'storm_observations#search_storm_telegrams'
  post 'storm_observations/create_storm_telegram', to: 'storm_observations#create_storm_telegram'
  get 'storm_observations/get_last_telegrams', to: 'storm_observations#get_last_telegrams'
  get 'storm_observations/input_storm_telegrams', to: 'storm_observations#input_storm_telegrams'
  put 'storm_observations/update_storm_telegram', to: 'storm_observations#update_storm_telegram'
  get 'storm_observations/get_conversion_params', to: 'storm_observations#get_conversion_params'
  post 'storm_observations/converter', to: 'storm_observations#converter'
  resources :storm_observations
  get 'agro_observations/search_agro_telegrams', to: 'agro_observations#search_agro_telegrams'
  post 'agro_observations/create_agro_telegram', to: 'agro_observations#create_agro_telegram'
  get 'agro_observations/get_last_telegrams', to: 'agro_observations#get_last_telegrams'
  get 'agro_observations/input_agro_telegrams', to: 'agro_observations#input_agro_telegrams'
  put 'agro_observations/update_agro_telegram', to: 'agro_observations#update_agro_telegram'
  resources :agro_observations
  post 'synoptic_observations/create_synoptic_telegram', to: 'synoptic_observations#create_synoptic_telegram'
  put 'synoptic_observations/update_synoptic_telegram', to: 'synoptic_observations#update_synoptic_telegram'
  get '/search_synoptic_telegrams', to: 'synoptic_observations#search_synoptic_telegrams'
  get 'synoptic_observations/synoptic_storm_telegrams', to: 'synoptic_observations#synoptic_storm_telegrams'
  get 'synoptic_observations/heat_donbass_show', to: 'synoptic_observations#heat_donbass_show'
  get 'synoptic_observations/get_temps', to: 'synoptic_observations#get_temps'
  get 'synoptic_observations/input_synoptic_telegrams', to: 'synoptic_observations#input_synoptic_telegrams'
  get 'synoptic_observations/get_last_telegrams', to: 'synoptic_observations#get_last_telegrams'
  get 'synoptic_observations/get_conversion_params', to: 'synoptic_observations#get_conversion_params'
  post 'synoptic_observations/converter', to: 'synoptic_observations#converter'
  get 'synoptic_observations/get_meteoparams', to: 'synoptic_observations#get_meteoparams'
  resources :synoptic_observations
  delete 'pollution_values/delete_value/:id', to: 'pollution_values#delete_value'
  resources :pollution_values
  get 'measurements/weather_update', to: 'measurements#weather_update'
  get 'measurements/get_weather_and_concentrations', to: 'measurements#get_weather_and_concentrations'
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
  get 'measurements/observations_quantity', to: 'measurements#observations_quantity'
  get 'measurements/wind_rose', to: 'measurements#wind_rose'
  post 'measurements/print_wind_rose', to: 'measurements#print_wind_rose'
  get 'measurements/print_wind_rose', to: 'measurements#print_wind_rose'
  get 'measurements/calc_normal_volume', to: 'measurements#calc_normal_volume'
  resources :measurements
  resources :materials
  resources :posts
  resources :cities
  resources :stations
  resources :audits
  resources :crop_conditions
  resources :crop_dec_conditions
  resources :crop_damages
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
  get 'bulletins/new_tv_bulletin', to: 'bulletins#new_tv_bulletin'
  get 'bulletins/new_storm_bulletin', to: 'bulletins#new_storm_bulletin'
  get 'bulletins/new_holiday_bulletin', to: 'bulletins#new_holiday_bulletin'
  get 'bulletins/:id/bulletin_show', to: 'bulletins#bulletin_show'
  get 'bulletins/list', to: 'bulletins#list'
  get 'bulletins/help_show', to: 'bulletins#help_show'
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
  root 'sessions#new' #'registers#index'
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
