class CreateCropConditions < ActiveRecord::Migration
  def change
    create_table :crop_conditions do |t|
      t.integer :agro_observation_id
      t.integer :crop_code, null: false                             # код из справочника
      t.integer :development_phase_1                                # 3 92 1 1 FF фаза развития растения
      t.integer :development_phase_2                                # 3 92 1 2 FF фаза развития растения
      t.integer :development_phase_3                                # 3 92 1 3 FF фаза развития растения
      t.integer :development_phase_4                                # 3 92 1 4 FF фаза развития растения
      t.integer :development_phase_5                                # 3 92 1 5 FF фаза развития растения
      t.integer :assessment_condition_1                             # 3 92 1 1 Ov оценка состояния табл. 5
      t.integer :assessment_condition_2                             # 3 92 1 2 Ov оценка состояния табл. 5
      t.integer :assessment_condition_3                             # 3 92 1 3 Ov оценка состояния табл. 5
      t.integer :assessment_condition_4                             # 3 92 1 4 Ov оценка состояния табл. 5
      t.integer :assessment_condition_5                             # 3 92 1 5 Ov оценка состояния табл. 5
      t.integer :agricultural_work_1                                # 3 92 6 1 PrPrPr сельскохозяйственная работа доп. 4
      t.integer :agricultural_work_2                                # 3 92 6 2 PrPrPr сельскохозяйственная работа доп. 4
      t.integer :agricultural_work_3                                # 3 92 6 3 PrPrPr сельскохозяйственная работа доп. 4
      t.integer :agricultural_work_4                                # 3 92 6 4 PrPrPr сельскохозяйственная работа доп. 4
      t.integer :agricultural_work_5                                # 3 92 6 5 PrPrPr сельскохозяйственная работа доп. 4
      t.integer :damage_plants_1                                    # 3 92 7 1 PvPvPv характер повреждения растений доп.3
      t.integer :damage_plants_2                                    # 3 92 7 2 PvPvPv характер повреждения растений доп.3
      t.integer :damage_plants_3                                    # 3 92 7 3 PvPvPv характер повреждения растений доп.3
      t.integer :damage_plants_4                                    # 3 92 7 4 PvPvPv характер повреждения растений доп.3
      t.integer :damage_plants_5                                    # 3 92 7 5 PvPvPv характер повреждения растений доп.3
      t.integer :damage_volume_1                                    # 3 92 7 1 Cv степень охвата растений повреждениями табл. 10
      t.integer :damage_volume_2                                    # 3 92 7 2 Cv степень охвата растений повреждениями табл. 10
      t.integer :damage_volume_3                                    # 3 92 7 3 Cv степень охвата растений повреждениями табл. 10
      t.integer :damage_volume_4                                    # 3 92 7 4 Cv степень охвата растений повреждениями табл. 10
      t.integer :damage_volume_5                                    # 3 92 7 5 Cv степень охвата растений повреждениями табл. 10

      t.timestamps null: false
    end
  end
end
