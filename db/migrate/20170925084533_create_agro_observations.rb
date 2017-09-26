class CreateAgroObservations < ActiveRecord::Migration
  def change
    create_table :agro_observations do |t|
      t.string :telegram_type, null: false, default: "ЩЭАГЯ"  # ЩЭАГЯ - ежедневная, ЩЭАГУ - декадная
      t.integer :station_id, null: false                      # ссылка на станцию
      t.date :date_dev, null: false                           # дата ввода наблюдения
      t.integer :day_obs, null: false                         # YY день или номер последнего дня декады 10, 20, 28, 29, 30, 31
      t.integer :month_obs, null: false                       # MM месяц
      t.integer :telegram_num, null: false, default: 1        # B0 порядковый номер телеграммы 1..8
      t.string  :telegram, null: false                        # текст телеграммы

      t.timestamps null: false
    end
  end
end
