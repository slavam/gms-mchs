class ChangeTelegramTypeToAgroDecObservations < ActiveRecord::Migration
  def change
    change_column(:agro_dec_observations, :telegram, :text)
  end
end
