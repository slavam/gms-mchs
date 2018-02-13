class CropDamage < ActiveRecord::Base
  belongs_to :agro_observation

  def height_snow_cover_rail_to_s(value)
    if value == 0
      "Снегосъемка не проводилась"
    elsif value == 997
      "Меньше 0.5"
    else
      value.to_s
    end
  end

  def thermometer_index_to_s
    term = ["", "Коробка Низенькова",
        "ЕДТУК",
        "АМ-17",
        "АМ-2М",
        "ТЕТ-2",
        "АМ-29А",
        "Вытяжные термометры"]
    term[self.thermometer_index]
  end
end
