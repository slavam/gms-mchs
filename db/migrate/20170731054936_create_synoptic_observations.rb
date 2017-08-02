class CreateSynopticObservations < ActiveRecord::Migration
  def change
    create_table :synoptic_observations do |t|
      t.date :date  # дата наблюдения
      t.integer :term # сорк
      t.string  :telegram # текст телеграммы
      t.integer :station_id # ссылка на станцию
      # t.string  :distinctive_group # различительная группа
      # 1 00 iR показатель наличия группы 6 1819
      # 1 00 iХ показатель наличия группы 7 1860
      t.integer :cloud_base_height                    # 1 00 h высота нижней границы облачности 1600 0..9, nil
      t.integer :visibility_range                     # 1 00 VV метеорологическая дальность видимости 4377 0..99, nil
      t.integer :cloud_amount_1                       # 1 0 N общее количество облаков 2700 0..9, nil
      t.integer :wind_direction                       # 1 0 dd направление ветра 0877 0..36, 99
      t.integer :wind_speed_avg                       # 1 0 ff средняя скорость ветра в метрах в секунду
      t.decimal :temperature, precision: 5, scale: 1  # 1 1 TTT температура воздуха с десятыми долями градуса Цельсия
      t.decimal :temperature_dew_point, precision: 5, scale: 1      # 1 2 TdTdTd значение точки росы с десятыми долями градуса Цельсия
      t.decimal :pressure_at_station_level, precision: 6, scale: 1  # 1 3 P0P0P0P0 давление воздуха на уровне станции с десятыми долями гектопаскаля
      t.decimal :pressure_at_sea_level, precision: 6, scale: 1      # 1 4 PPPP давление воздуха на уровне моря с десятыми долями гектопаскаля
      t.integer :pressure_tendency_characteristic                   # 1 5 a характеристика барической тенденции 0200 0..8
      t.decimal :pressure_tendency, precision: 6, scale: 1          # 1 5 ppp значение барической тенденции с десятыми долями гектопаскаля
      t.integer :precipitation_1                                    # 1 6 RRR количество осадков 1..999
      t.integer :precipitation_time_range_1                         # 1 6 tR период времени замера осадков 4019 0..9
      t.integer :weather_in_term                                    # 1 7 ww погода в срок наблюдений 0..99 4677
      t.integer :weather_past_1                                     # 1 7 W1 прошедшая погода 0..9 4561
      t.integer :weather_past_2                                     # 1 7 W2 прошедшая погода 0..9 4561
      t.integer :cloud_amount_2                                     # 1 8 Nh количество облаков 2700 0..9, nil
      t.integer :clouds_1                                           # 1 8 CL облака вертикального развития 0513 0..9, nil
      t.integer :clouds_2                                           # 1 8 CM облака среднего яруса 0515 0..9, nil
      t.integer :clouds_3                                           # 1 8 CH облака верхнего яруса 0509 0..9, nil
      t.decimal :temperature_dey_max, precision: 5, scale: 1        # 3 1 TxTxTx максимальная за день температура воздуха с десятыми долями градуса Цельсия
      t.decimal :temperature_night_min, precision: 5, scale: 1      # 3 2 TnTnTn минимальная за ночь температура воздуха с десятыми долями градуса Цельсия
      t.integer :underlying_surface_сondition                       # 3 4 E' состояние подстилающей поверхности 0975 0..9, nil
      t.integer :snow_cover_height                                  # 3 4 sss высота снежного покрова в сантиметрах 3889 1..999
      t.decimal :sunshine_duration, precision: 5, scale: 1          # 3 5 SSS продолжительность солнечного сияния с десятыми долями часа
      t.integer :cloud_amount_3                                     # 3 8 Ns общее количество облаков 2700 0..9, nil
      t.integer :cloud_form                                         # 3 8 C форма облаков 0500 0..9, nil
      t.integer :cloud_height                                       # 3 8 hshs высота нижней границы слоя облаков 1677 0..99
      t.string  :weather_data_add                                   # 3 9 SpSpspsp дополнительная информация о погоде 3778
      t.integer :soil_surface_condition_1                           # 5 1 E состояние поверхности почвы без снега 0901 0..9, nil
      t.integer :temperature_soil                                   # 5 1 TgTg температура поверхности почвы
      t.integer :soil_surface_condition_2                           # 5 3 E состояние поверхности почвы без снега 0901 0..9, nil
      t.decimal :temperature_soil_min, precision: 5, scale: 1       # 5 3 TgTg минимальная за ночь температура почвы с десятыми долями градуса Цельсия
      t.integer :temperature_2cm_min                                # 5 5 T2T2 минимальная температура воздуха на высоте 2 см от поверхности почвы
      t.integer :precipitation_2                                    # 5 6 RRR количество осадков 3590 0..999
      t.integer :precipitation_time_range_2                         # 5 6 tR период времени замера осадков 4019 0..9
      # 5 9 TAAA мощность экспозиционной дозы гамма-излучения

      t.timestamps null: false
    end
  end
end
