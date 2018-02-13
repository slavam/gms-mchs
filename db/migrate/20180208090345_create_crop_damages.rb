class CreateCropDamages < ActiveRecord::Migration
  def change
    create_table :crop_damages do |t|
      t.integer :agro_observation_id
      t.integer :crop_code, null: false                             # код из справочника
      t.integer :height_snow_cover_rail                             # 3 95 ststst средняя высота (см) снежного покрова по рейке табл. 13
      t.integer :depth_soil_freezing                                # 3 95 4 HmHmHm глубина промерзания грунта (см)
      t.integer :thermometer_index                                  # 3 95 5 n прибор для измерения температуры грунта табл.17
      t.integer :temperature_dec_min_soil3                          # 3 95 5 t3t3 температура грунта на глубине 3 см

      t.timestamps null: false
    end
  end
end
