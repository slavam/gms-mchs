class ChangeTelegramDateTypeToStormObservations < ActiveRecord::Migration
  def change
    change_column :storm_observations, :telegram_date, :datetime
  end
end
