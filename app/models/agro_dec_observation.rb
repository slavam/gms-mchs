class AgroDecObservation < ActiveRecord::Base
  belongs_to :station
  has_many :crop_dec_conditions, :dependent => :destroy
  audited
  def self.last_50_telegrams
    AgroDecObservation.all.limit(50).order(:date_dev, :updated_at).reverse_order
  end
  
  def self.short_last_50_telegrams(user)
    if user.role == 'specialist'
      all_fields = AgroDecObservation.where("station_id = ? and date_dev > ?", user.station_id, Time.now.utc-45.days).order(:date_dev, :updated_at).reverse_order
    else
      all_fields = AgroDecObservation.all.limit(50).order(:date_dev, :updated_at).reverse_order
    end
    stations = Station.all.order(:id)
    all_fields.map do |rec|
      {id: rec.id, date: rec.date_dev, station_name: stations[rec.station_id-1].name, telegram: rec.telegram}
    end
  end
  
  # def assessment_condition_to_s(value)
  #   assessments = ["Полная гибель", "Очень плохое", "Плохое", "Удовлетворительное", "Хорошее", "Отличное"]
  #   assessments[value]
  # end
end
