class CreateSeaObservations < ActiveRecord::Migration
  def change
    create_table :sea_observations do |t|
      t.date    :date_dev, null: false    # дата ввода наблюдения
      t.integer :term, null: false        # срок наблюдений 9, 15, 21
      t.integer :day_obs, null: false     # YY день 
      t.integer :station_id, null: false  # ссылка на станцию
      t.string  :telegram, null: false    # текст телеграммы

      t.timestamps null: false
    end
  end
end
