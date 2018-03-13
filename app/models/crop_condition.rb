class CropCondition < ActiveRecord::Base
  belongs_to :agro_observation
  
  # def assessment_condition_to_s(value)
  #   assessments = ["Полная гибель", "Очень плохое", "Плохое", "Удовлетворительное", "Хорошее", "Отличное"]
  #   assessments[value]
  # end
  
  def index_weather_to_s(value)
    indexes = ["", "Условия неблагоприятные", "Работы велись с перерывами", "Условия благоприятные"]
    indexes[value]
  end
  
  # def damage_volume_to_s(value)
  #   volumes = ["", "Повреждены отдельные растения (до 10%)", "Повреждено немного растений (11-20%)", 
  #     "Повреждено много растений (21-50%)", "Повреждено большинство растений (51-80%)", "Повреждены все растения (81-100%)"]
  #   volumes[value]
  # end
end
