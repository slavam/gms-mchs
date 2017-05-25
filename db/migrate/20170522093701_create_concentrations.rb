class CreateConcentrations < ActiveRecord::Migration
  def change
    create_table :concentrations do |t|
      t.integer :city_id
      t.integer :site_id
      t.integer :year
      t.integer :month
      t.integer :substance_id
      t.float :value_w0
      t.integer :number_w0
      t.float :value_wN
      t.integer :number_wN
      t.float :value_wE
      t.integer :number_wE
      t.float :value_wS
      t.integer :number_wS
      t.float :value_wW
      t.integer :number_wW
    
      t.timestamps null: false
    end
  end
end
