class ChangeTelegramTypeToAgroObservations < ActiveRecord::Migration
  def change
    change_column(:agro_observations, :telegram, :text)
  end
end
