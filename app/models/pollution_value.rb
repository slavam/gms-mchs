class PollutionValue < ActiveRecord::Base
  belongs_to :material
  belongs_to :measurement
end
