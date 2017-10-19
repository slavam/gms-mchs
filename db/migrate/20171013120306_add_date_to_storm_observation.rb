class AddDateToStormObservation < ActiveRecord::Migration
  def change
    add_column :storm_observations, :telegram_date, :date
  end
end
