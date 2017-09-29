class CreateStormObservations < ActiveRecord::Migration
  def change
    create_table :storm_observations do |t|
      t.timestamps  :registred_at, null: false
      t.string      :telegram_type, null: false, default: "ЩЭОЯЮ"  # ЩЭОЯЮ - начало, усиление ЩЭОЗМ - конец, ослабление
      t.integer     :station_id, null: false                      # ссылка на станцию
      t.integer     :day_event, null: false                       # YY день нечала/конца явления
      t.integer     :hour_event                                   # GG час
      t.integer     :minute_event                                 # GG минуты
      t.string      :telegram, null: false                        # текст телеграммы

      t.timestamps null: false
    end
  end
end
