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
  
end
