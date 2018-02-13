class AddIndexWeatherToCropConditions < ActiveRecord::Migration
  def change
    add_column :crop_conditions, :index_weather_1, :integer # 3 92 6 1 Xr благоприятные погодные условия табл. 20
    add_column :crop_conditions, :index_weather_2, :integer # 3 92 6 2 Xr благоприятные погодные условия табл. 20
    add_column :crop_conditions, :index_weather_3, :integer # 3 92 6 3 Xr благоприятные погодные условия табл. 20
    add_column :crop_conditions, :index_weather_4, :integer # 3 92 6 4 Xr благоприятные погодные условия табл. 20
    add_column :crop_conditions, :index_weather_5, :integer # 3 92 6 5 Xr благоприятные погодные условия табл. 20
  end
end
