class CreateBulletins < ActiveRecord::Migration
  def change
    create_table :bulletins do |t|
      t.date :report_date
      t.string :curr_number
      t.string :synoptic1
      t.string :synoptic2
      t.text :storm
      t.text :forecast_day
      t.text :forecast_period
      t.text :forecast_advice
      t.text :forecast_orientation
      t.text :forecast_sea_day
      t.text :forecast_sea_period
      t.text :meteo_data
      t.text :agro_day_review
      t.text :climate_data
    end
  end
end
