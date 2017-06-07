class CreateMeasurements < ActiveRecord::Migration
  def change
    create_table :measurements do |t|
      t.integer :post_id
      t.date  :date
      t.integer :term
      t.string :rhumb
      t.integer :wind_direction
      t.integer :wind_speed
      t.decimal :temperature, precision: 4, scale: 1
      t.integer :phenomena
      t.integer :relative_humidity
      t.decimal :partial_pressure, precision: 4, scale: 1
      t.integer :atmosphere_pressure

      t.timestamps null: false
    end
  end
end
