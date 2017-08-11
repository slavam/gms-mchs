class AddIndexToSynopticObservations < ActiveRecord::Migration
  def change
    add_index :synoptic_observations, [:date, :term, :station_id], unique: true
  end
end
