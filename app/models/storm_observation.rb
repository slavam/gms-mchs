class StormObservation < ActiveRecord::Base
  belongs_to :station
  audited
  
  def event_time
    self.hour_event.to_s.rjust(2, '0')+':'+self.minute_event.to_s.rjust(2, '0')
  end
end
