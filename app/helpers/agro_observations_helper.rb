module AgroObservationsHelper
  def precipitation_to_s(value)
    case value
      when 0
        "Осадков не было"
      when 1..988
        value.to_s
      when 989
        "989 и больше"
      when 990
        "Следы осадков"
      when 991..999
        ((value - 990)*0.1).round(2).to_s
    end
  end
  def assessment_condition_to_s(value)
    assessments = ["Полная гибель", "Очень плохое", "Плохое", "Удовлетворительное", "Хорошее", "Отличное"]
    assessments[value]
  end
  def damage_volume_to_s(value)
    volumes = ["", "Повреждены отдельные растения (до 10%)", "Повреждено немного растений (11-20%)", 
      "Повреждено много растений (21-50%)", "Повреждено большинство растений (51-80%)", "Повреждены все растения (81-100%)"]
    volumes[value]
  end
end
