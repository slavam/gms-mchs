class SeaObservation < ActiveRecord::Base
  validates :date_dev, presence: true
  validates :term, presence: true
  validates :day_obs, presence: true
  validates :station_id, presence: true
  validates :telegram, presence: true
  belongs_to :station
  audited
  
  def self.last_50_telegrams
    SeaObservation.all.limit(50).order(:date_dev, :term, :updated_at).reverse_order
  end
  
  def self.short_last_50_telegrams
    all_fields = SeaObservation.all.limit(50).order(:date_dev, :term, :updated_at).reverse_order
    stations = Station.all.order(:id)
    all_fields.map do |rec|
      {id: rec.id, date: rec.date_dev, station_name: stations[rec.station_id-1].name, telegram: rec.telegram}
    end
  end
end
