class ChangeDateDevTypeToAgroObservations < ActiveRecord::Migration
  def change
    change_column :agro_observations, :date_dev, :datetime
  end
end
