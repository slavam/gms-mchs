class AgroObservation < ActiveRecord::Base
  belongs_to :station
  has_many :crop_conditions, :dependent => :destroy
  has_many :crop_damages, :dependent => :destroy
  audited
  def self.last_50_telegrams
    AgroObservation.all.limit(50).order(:date_dev, :updated_at).reverse_order
  end
  
  def self.short_last_50_telegrams(user)
    if user.role == 'specialist'
      all_fields = AgroObservation.where("station_id = ? and date_dev > ?", user.station_id, Time.now.utc-45.days).order(:date_dev, :updated_at).reverse_order
    else
      all_fields = AgroObservation.all.limit(50).order(:date_dev, :updated_at).reverse_order
    end
    stations = Station.all.order(:id)
    all_fields.map do |rec|
        {id: rec.id, date: rec.date_dev, station_name: stations[rec.station_id-1].name, telegram: rec.telegram}
      end
  end
  
  # def precipitation_to_s(value)
  #   case value
  #     when 0
  #       "Осадков не было"
  #     when 1..988
  #       value.to_s
  #     when 989
  #       "989 и больше"
  #     when 990
  #       "Следы осадков"
  #     when 991..999
  #       ((value - 990)*0.1).round(2).to_s
  #   end
  # end
  
  def percipitation_type_to_s
    case self.percipitation_type
      when 1
        "Обложной дождь"
      when 2
        "Ливневой дождь"
      when 3
        "Морось"
      when 4
        "Град"
      when 5
        "Снег"
    end
  end
  
  def dew_intensity_to_s(value)
    if value == 0
      return "Слабая"
    elsif value == 1
      return "Умеренная"
    elsif value == 2
      return "Сильная"
    else 
      return ''
    end
  end
  
  def state_top_layer_soil_to_s
    case self.state_top_layer_soil
      when 0
        "Покрыт снегом"
      when 1
        "Переувлажненный. Текучий"
      when 2
        "Сильно увлажненный. Липкий"
      when 3
        "Хорошо увлажненный. Мягкопластичный"
      when 4
        "Слабо увлажненный. Твердопластичный"
      when 5
        "Сухой. Твердый или сыпучий"
      when 6
        "Мерзлый. Смерзшийся"    
    end
  end
  
end
