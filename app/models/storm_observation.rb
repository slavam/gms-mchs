class StormObservation < ActiveRecord::Base
  belongs_to :station
  audited
  
  def self.last_50_telegrams
    StormObservation.all.limit(50).order(:telegram_date, :updated_at).reverse_order
  end
  
  def event_time
    self.hour_event.to_s.rjust(2, '0')+':'+self.minute_event.to_s.rjust(2, '0')
  end
end
