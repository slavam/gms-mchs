class AddFieldsToAgroObservations < ActiveRecord::Migration
  def change
    add_column :agro_observations, :temperature_max_12, :integer            # 3 90 TxTx максимальная температура воздуха за 12 дневных часов
    add_column :agro_observations, :temperature_avg_24, :decimal, precision: 5, scale: 1         # 3 90 1 T24T24T24 средняя за сутки температура воздуха табл. 2
    add_column :agro_observations, :temperature_min_24, :integer                                 # 3 90 3 TnTn минимальная за сутки температура воздуха
    add_column :agro_observations, :temperature_min_soil_24, :integer                            # 3 90 4 TgTg минимальная за сутки температура на поверхности почвы
    add_column :agro_observations, :percipitation_24, :integer                                   # 3 90 5 R24R24R24 количество осадков (мм), выпавших за сутки табл.4
    add_column :agro_observations, :percipitation_type, :integer                                 # 3 90 5 Rx вид осадков 1..5, nil
    add_column :agro_observations, :percipitation_12, :integer                                   # 3 90 6 R12R12R12 количество осадков за 12 ночных часов табл. 4
    add_column :agro_observations, :wind_speed_max_24, :integer                                  # 3 90 7 fxfx максимальная за сутки скорость ветра (м/с)
    add_column :agro_observations, :saturation_deficit_max_24, :integer                          # 3 90 7 DxDx максимальный дефицит насыщения воздуха за сутки (гПа)
    add_column :agro_observations, :duration_dew_24, :integer                                    # 3 90 8 XX продолжительность росы (часов) за сутки
    add_column :agro_observations, :dew_intensity_max, :integer                                  # 3 90 8 Z максимальная за сутки интенсивность росы 0..2
    add_column :agro_observations, :dew_intensity_8, :integer                                    # 3 90 8 Z1 интенсивность росы в срок 8 часов 0..2
                                                                            # ежедневная телеграмма группа 333 зона 91
    add_column :agro_observations, :sunshine_duration_24, :integer                               # 3 91 S24S24 продолжительность солнечного сияния (часов) за предыдущие сутки
    add_column :agro_observations, :state_top_layer_soil, :integer                               # 3 91 Ml состояние верхнего слоя грунта табл. 19
    add_column :agro_observations, :temperature_field_5_16, :integer                             # 3 91 1 t5t5 температура грунта на глубине 5 см в поле в 16 часов
    add_column :agro_observations, :temperature_field_10_16, :integer                            # 3 91 1 t10t10 температура грунта на глубине 10 см в поле в 16 часов
    add_column :agro_observations, :temperature_avg_soil_5, :integer                             # 3 91 2 t_5t_5 средняя за предыдущие сутки температура грунта на глубине 5 см 
    add_column :agro_observations, :temperature_avg_soil_10, :integer                            # 3 91 2 t_10t_10 средняя за предыдущие сутки температура грунта на глубине 10 см 
    add_column :agro_observations, :saturation_deficit_avg_24, :integer                          # 3 91 3 DeDe средний дефицит насыщения воздуха за минувшие сутки (гПа)
    add_column :agro_observations, :relative_humidity_min_24, :integer                           # 3 91 3 uxux минимальная относительная влажность воздуха за минувшие сутки (%)
  end
end
