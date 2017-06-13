class AddIndexToMeasurements < ActiveRecord::Migration
  def change
    add_index :measurements, [:date, :term, :post_id], unique: true
  end
end
