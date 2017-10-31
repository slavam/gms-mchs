class Station < ActiveRecord::Base
  has_many :synoptic_observations
end