class ChangeDateDevTypeToSeaObservations < ActiveRecord::Migration
  def change
    change_column :sea_observations, :date_dev, :datetime
  end
end
