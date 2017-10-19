class AgroObservation < ActiveRecord::Base
  belongs_to :station
  audited
  def self.last_50_telegrams
    AgroObservation.all.limit(50).order(:date_dev, :updated_at).reverse_order
  end
end
