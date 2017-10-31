class AgroObservation < ActiveRecord::Base
  belongs_to :station
  audited
  def self.last_50_telegrams
    AgroObservation.all.limit(50).order(:date_dev, :updated_at).reverse_order
  end
  
  def self.short_last_50_telegrams
    all_fields = AgroObservation.all.limit(50).order(:date_dev, :updated_at).reverse_order
    stations = Station.all.order(:id)
    all_fields.map do |rec|
        {id: rec.id, date: rec.date_dev, station_name: stations[rec.station_id-1].name, telegram: rec.telegram}
      end
  end
end
