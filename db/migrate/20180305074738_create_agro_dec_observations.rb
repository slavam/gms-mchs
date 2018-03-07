class CreateAgroDecObservations < ActiveRecord::Migration
  def change
    create_table :agro_dec_observations do |t|
      t.date    :date_dev                                           # дата наблюдения
      t.integer :day_obs
      t.integer :month_obs
      t.string  :telegram                                           # текст телеграммы
      t.integer :station_id                                         # ссылка на станцию
      # t.integer :decade_last_day                                    # YY номер последнего дня декады 10, 20, 28, 29, 30, 31
      t.integer :telegram_num                                       # B0 порядковый номер телеграммы 1..8
            # декадная метеорологическая информация
            # декадная телеграмма группа 111 зоны 90
      t.integer :temperature_dec_avg_delta                          # 1 90 T0T0 отклонение средней за декаду температуры от среднего многолетнего (целые градусы Цельсия)
      t.decimal :temperature_dec_avg, precision: 5, scale: 1        # 1 1 TTT средняя температура воздуха за декаду с десятыми долями градуса Цельсия
      t.integer :temperature_dec_max                                # 1 2 TxTx максимум температуры воздуха за декаду (целые градусы Цельсия)
      t.integer :hot_dec_day_num                                    # 1 2 ntx количество дней за декаду с макс. температурой за сутки 30 и выше 1..11, nil
      t.integer :temperature_dec_min                                # 1 3 TnTn минимум температуры воздуха за декаду (целые градусы Цельсия)
      t.integer :dry_dec_day_num                                    # 1 3 nu количество дней за декаду с мин. за сутки относительной влажностью воздуха 30% и меньше 1..11, nil
      t.integer :temperature_dec_min_soil                           # 1 4 TgTg минимум температуры поверхности грунта за декаду (целые градусы Цельсия)
      t.integer :cold_soil_dec_day_num                              # 1 4 ntg количество дней за декаду с мин. температурой за сутки на поверхности почвы -20 и ниже 1..11, nil
      t.integer :precipitation_dec                                  # 1 5 RRR количество осадков за декаду 0..999 табл. 4
      t.integer :wet_dec_day_num                                    # 1 5 nR1 количество дней за декаду с количеством осадков за сутки 1 мм и более 1..11, nil
      t.integer :precipitation_dec_percent                          # 1 6 R0R0R0R0 количество осадков за декаду в процентах от среднего многолетнего
      t.integer :wind_speed_dec_max                                 # 1 7 fxfx максимальная скорость ветра в метрах в секунду за декаду
      t.integer :wind_speed_dec_max_day_num                         # 1 7 nf количество дней за декаду с макс. скоростью ветра за сутки 15м/с и более 1..11, nil
      t.integer :duster_dec_day_num                                 # 1 7 nb количество дней за декаду с пылевыми бурями 1..11, nil
            # декадная телеграмма группа 111 зона 91
      t.integer :temperature_dec_max_soil                           # 1 91 TzTz максимум температуры поверхности грунта за декаду (целые градусы Цельсия)
      t.integer :sunshine_duration_dec                              # 1 1 SdSdSd продолжительность солнечного сияния за декаду
      t.integer :freezing_dec_day_num                               # 1 1 n0 количество дней за декаду с заморозками 1..11, nil
      t.integer :temperature_dec_avg_soil10                         # 1 2 t10t10 средняя за декаду температура почвы на глубине 10 см
      t.integer :temperature25_soil10_dec_day_num                   # 1 2 n25 количество суток за декаду с температурой почвы на глубине 10 см 25 и выше 1..11, nil
      t.integer :dew_dec_day_num                                    # 1 2 nr количество суток за декаду с росой 1..11, nil
      t.integer :saturation_deficit_dec_avg                         # 1 3 DdDd средний дефицит насыщения за декаду (гПа)
      t.integer :relative_humidity_dec_avg                          # 1 3 UdUd средняя относительная влажность воздуха за декаду (%)
      t.integer :percipitation_dec_max                              # 1 4 RxRxRx суточный максимум осадков за декаду (мм)
      t.integer :percipitation5_dec_day_num                         # 1 4 nR5 количество суток за декаду с количеством осадков 5 мм и более

      t.timestamps null: false
    end
  end
end
