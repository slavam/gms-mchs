class Station < ActiveRecord::Base
  has_many :synoptic_observations
  def self.station_id_by_code
    stations = Station.all.order(:id)
    ret = {}
    stations.each { |s| ret[s.code] = s.id }
    ret
  end
end