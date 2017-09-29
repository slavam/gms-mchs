class AgroObservation < ActiveRecord::Base
  belongs_to :station
  audited
end
