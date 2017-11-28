class CreateLaboratories < ActiveRecord::Migration
  def change
    create_table :laboratories do |t|
      t.string  :name, null: false                          # название лаборатории
      t.decimal :calibration_factor, precision: 6, scale: 3 # Градуировочный коэфициент		
      t.decimal :aliquot_volume, precision: 5, scale: 2     # Объем аликвоты		
      t.decimal :solution_volume, precision: 5, scale: 2    # Объем раствора	
      t.decimal :sample_volume, precision: 5, scale: 2      # Объем отобраной пробы

      t.timestamps null: false
    end
  end
end
