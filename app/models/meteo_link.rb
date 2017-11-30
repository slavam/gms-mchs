class MeteoLink < ActiveRecord::Base
  validates :address, :format => URI::regexp(%w(http https))
end
