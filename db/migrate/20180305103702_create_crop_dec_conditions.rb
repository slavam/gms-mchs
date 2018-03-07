class CreateCropDecConditions < ActiveRecord::Migration
  def change
    create_table :crop_dec_conditions do |t|
            # декадная агрометеорологическая информация 
            # декадная телеграмма группа 222 зона 92
            # вынести в отдельную таблицу!
      t.integer :agro_dec_observation_id
      t.integer :crop_id                                            # 2 92 KpKpKp культура
      t.integer :plot_id                                            # 2 1 NNN участок наблюдения
      t.integer :agrotechnology                                     # 2 1 Af показатель наличия агротехнологии 1..7
      t.integer :development_phase_1                                # 2 2 1 FF фаза развития растения
      t.integer :development_phase_2                                # 2 2 2 FF фаза развития растения
      t.integer :development_phase_3                                # 2 2 3 FF фаза развития растения
      t.integer :development_phase_4                                # 2 2 4 FF фаза развития растения
      t.integer :development_phase_5                                # 2 2 5 FF фаза развития растения
      t.integer :day_phase_1                                        # 2 2 1 Ya день декады, когда наступила фаза
      t.integer :day_phase_2                                        # 2 2 2 Ya день декады, когда наступила фаза
      t.integer :day_phase_3                                        # 2 2 3 Ya день декады, когда наступила фаза
      t.integer :day_phase_4                                        # 2 2 4 Ya день декады, когда наступила фаза
      t.integer :day_phase_5                                        # 2 2 5 Ya день декады, когда наступила фаза
      t.integer :assessment_condition_1                             # 2 2 1 O оценка состояния на последний день декады табл. 5
      t.integer :assessment_condition_2                             # 2 2 2 O оценка состояния на последний день декады табл. 5
      t.integer :assessment_condition_3                             # 2 2 3 O оценка состояния на последний день декады табл. 5
      t.integer :assessment_condition_4                             # 2 2 4 O оценка состояния на последний день декады табл. 5
      t.integer :assessment_condition_5                             # 2 2 5 O оценка состояния на последний день декады табл. 5
      t.integer :clogging_weeds                                     # 2 3 Oz засорение посевов бурьяном
      t.integer :height_plants                                      # 2 3 BBB средняя высота рстений
      t.integer :number_plants                                      # 2 4 CpCpCpCp среднее количество растений на единицу площади
      t.integer :average_mass                                       # 2 5 CnCnCnCn средняя масса кукурузы или сахарной свеклы в граммах
      t.integer :agricultural_work_1                                # 2 6 1 PrPrPr сельскохозяйственная работа доп. 4
      t.integer :agricultural_work_2                                # 2 6 2 PrPrPr сельскохозяйственная работа доп. 4
      t.integer :agricultural_work_3                                # 2 6 3 PrPrPr сельскохозяйственная работа доп. 4
      t.integer :agricultural_work_4                                # 2 6 4 PrPrPr сельскохозяйственная работа доп. 4
      t.integer :agricultural_work_5                                # 2 6 5 PrPrPr сельскохозяйственная работа доп. 4
      t.integer :day_work_1                                         # 2 6 1 Yr день декады, когда началась работа
      t.integer :day_work_2                                         # 2 6 2 Yr день декады, когда началась работа
      t.integer :day_work_3                                         # 2 6 3 Yr день декады, когда началась работа
      t.integer :day_work_4                                         # 2 6 4 Yr день декады, когда началась работа
      t.integer :day_work_5                                         # 2 6 5 Yr день декады, когда началась работа
      t.integer :damage_plants_1                                    # 2 7 1 PvPvPv характер повреждения растений доп.3
      t.integer :damage_plants_2                                    # 2 7 2 PvPvPv характер повреждения растений доп.3
      t.integer :damage_plants_3                                    # 2 7 3 PvPvPv характер повреждения растений доп.3
      t.integer :damage_plants_4                                    # 2 7 4 PvPvPv характер повреждения растений доп.3
      t.integer :damage_plants_5                                    # 2 7 5 PvPvPv характер повреждения растений доп.3
      t.integer :day_damage_1                                       # 2 7 1 Yp день декады, когда отмечено повреждение растений
      t.integer :day_damage_2                                       # 2 7 2 Yp день декады, когда отмечено повреждение растений
      t.integer :day_damage_3                                       # 2 7 3 Yp день декады, когда отмечено повреждение растений
      t.integer :day_damage_4                                       # 2 7 4 Yp день декады, когда отмечено повреждение растений
      t.integer :day_damage_5                                       # 2 7 5 Yp день декады, когда отмечено повреждение растений
      t.integer :damage_level_1                                     # 2 0 1 Cn степень повреждения растений табл. 7, 8, 9
      t.integer :damage_level_2                                     # 2 0 2 Cn степень повреждения растений табл. 7, 8, 9
      t.integer :damage_level_3                                     # 2 0 3 Cn степень повреждения растений табл. 7, 8, 9
      t.integer :damage_level_4                                     # 2 0 4 Cn степень повреждения растений табл. 7, 8, 9
      t.integer :damage_level_5                                     # 2 0 5 Cn степень повреждения растений табл. 7, 8, 9
      t.integer :damage_volume_1                                    # 2 0 1 Cv степень охвата растений повреждениями табл. 10
      t.integer :damage_volume_2                                    # 2 0 2 Cv степень охвата растений повреждениями табл. 10
      t.integer :damage_volume_3                                    # 2 0 3 Cv степень охвата растений повреждениями табл. 10
      t.integer :damage_volume_4                                    # 2 0 4 Cv степень охвата растений повреждениями табл. 10
      t.integer :damage_volume_5                                    # 2 0 5 Cv степень охвата растений повреждениями табл. 10
      t.integer :damage_space_1                                     # 2 0 1 E0E0 площадь поля, охваченная повреждениями в %
      t.integer :damage_space_2                                     # 2 0 2 E0E0 площадь поля, охваченная повреждениями в %
      t.integer :damage_space_3                                     # 2 0 3 E0E0 площадь поля, охваченная повреждениями в %
      t.integer :damage_space_4                                     # 2 0 4 E0E0 площадь поля, охваченная повреждениями в %
      t.integer :damage_space_5                                     # 2 0 5 E0E0 площадь поля, охваченная повреждениями в %
            # декадная телеграмма группа 222 зона 93
      t.integer :number_spicas                                      # 2 93 riri количество колосков в колосе
      t.integer :num_bad_spicas                                     # 2 93 rk количество неразвитых колосков в колосе
      t.integer :number_stalks                                      # 2 93 1 C0C0C0C0 количество стеблей на 1 м2
      t.integer :stalk_with_spike_num                               # 2 93 2 CkCkCkCk количество стеблей с колосом на 1 м2
      t.integer :normal_size_potato                                 # 2 93 3 LeLe процент картофелин нормального размера от общего количества в кусте
      t.integer :losses                                             # 2 93 3 ZeZe потери в процентах
      t.integer :grain_num                                          # 2 93 4 rerere среднее количество зерен в колосе
      t.integer :bad_grain_percent                                  # 2 93 4 rm процент щуплых зерен
      t.integer :bushiness                                          # 2 93 5 MzMz кустистость зерновых
      t.integer :shoots_inflorescences                              # 2 93 5 VzVz побеги с соцветьями
      t.decimal :grain1000_mass, precision: 5, scale: 1             # 2 93 6 AbAbAbAb масса 1000 зерен (г) у зерновых с точностью до десятых
            # декадная телеграмма группа 222 зона 94
      t.integer :moisture_reserve_10                                # 2 94 W10W10W10 запас продуктивной влаги (мм) в слое грунта 0-100 см 
      t.integer :moisture_reserve_5                                 # 2 94 1 W5W5W5 запас продуктивной влаги (мм) в слое грунта 0-50 см 
      t.integer :soil_index                                         # 2 94 1 P показатель грунта табл. 12
      t.integer :moisture_reserve_2                                 # 2 94 2 W2W2 запас продуктивной влаги (мм) в слое грунта 0-20 см
      t.integer :moisture_reserve_1                                 # 2 94 2 W1W1 запас продуктивной влаги (мм) в слое грунта 0-10 см
      t.integer :temperature_water_2                                # 2 94 4 t2t2 средняя за декаду температура воды в чеке на глубине 2 см
      t.integer :depth_water                                        # 2 94 4 HwHw средняя за декаду уровень воды в чеке (см)
      t.integer :depth_groundwater                                  # 2 94 5 GbGbGbGb глубина залегания грунтовых вод (см) на последний день декады
      t.integer :depth_thawing_soil                                 # 2 94 6 HcHcHc глубина оттаивания грунта (см) на последний день декады
      t.integer :depth_soil_wetting                                 # 2 94 7 GpGpGp глубина промокания грунта (см)
            # декадная телеграмма группа 222 зона 95
      t.integer :height_snow_cover                                  # 2 95 sss средняя высота (см) снежного покрова на последний день декады табл. 13
      t.integer :snow_retention                                     # 2 95 1 H индекс снегозадержания табл.14
      t.integer :snow_cover                                         # 2 95 1 E характеристика залегания снежного покрова табл. 15
      t.decimal :snow_cover_density, precision: 5, scale: 2         # 2 95 1 MpMp средняя плотность снежного покрова (г/см2) в сотых долях
      t.integer :number_measurements_0                              # 2 95 2 C0 количество промеров с высотой снежного покрова 0 см
      t.integer :number_measurements_3                              # 2 95 2 C3 количество промеров с высотой снежного покрова 1-3 см
      t.integer :number_measurements_30                             # 2 95 2 C30 количество промеров с высотой снежного покрова >30 см табл. 16
      t.integer :ice_crust                                          # 2 95 2 L расширение ледяной корки (баллы)
      t.integer :thickness_ice_cake                                 # 2 95 3 LaLa среднее значение толщины (мм) ледяной корки
      t.integer :depth_thawing_soil_2                               # 2 95 3 HcHc глубина оттаивания грунта (см) на последний день декады
      t.integer :depth_soil_freezing                                # 2 95 4 HpHpHp глубина промерзания грунта (см) на последний день декады
      t.integer :thaw_days                                          # 2 95 4 nq количество дней с оттепелью табл. 3
      t.integer :thermometer_index                                  # 2 95 5 n прибор для измерения температуры грунта табл.17
      t.integer :temperature_dec_min_soil3                          # 2 95 5 t3t3 минимальная за декаду температура грунта на глубине 3 (20) см
      t.integer :height_snow_cover_rail                             # 2 95 6 ststst высота (см) снежного покрова по рейке
      t.integer :viable_method                                      # 2 95 7 P5 способ определения жизнеспособности зимующих культур табл.18
      t.integer :soil_index_2                                       # 2 95 7 P показатель грунта табл. 12
      t.integer :losses_1                                           # 2 95 7 E1E1 потери в процентах в первом образце
      t.integer :losses_2                                           # 2 95 8 E2E2 потери в процентах во 2 образце
      t.integer :losses_3                                           # 2 95 8 E3E3 потери в процентах в 3 образце
      t.integer :losses_4                                           # 2 95 0 E4E4 потери в процентах в 4 образце
      t.integer :temperature_dead50                                 # 2 95 0 K5K5 температура в морозильной камере, при которой погибло более 50% растений

      t.timestamps null: false
    end
  end
end
