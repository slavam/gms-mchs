class StormObservation < ActiveRecord::Base
  belongs_to :station
  audited
  
  def self.last_50_telegrams
    StormObservation.all.limit(50).order(:telegram_date, :updated_at).reverse_order
  end
  
  def self.short_last_50_telegrams
    all_fields = StormObservation.all.limit(50).order(:telegram_date, :updated_at).reverse_order
    stations = Station.all.order(:id)
    all_fields.map do |rec|
      {id: rec.id, date: rec.telegram_date, station_name: stations[rec.station_id-1].name, telegram: rec.telegram}
    end
  end
  
  def event_time
    self.hour_event.to_s.rjust(2, '0')+':'+self.minute_event.to_s.rjust(2, '0')
  end
end
