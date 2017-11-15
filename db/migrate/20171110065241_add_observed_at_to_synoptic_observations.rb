class AddObservedAtToSynopticObservations < ActiveRecord::Migration
  def change
    add_column(:synoptic_observations, :observed_at, :datetime)
  end
end
