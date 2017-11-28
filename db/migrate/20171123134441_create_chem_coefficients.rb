class CreateChemCoefficients < ActiveRecord::Migration
  def change
    create_table :chem_coefficients do |t|
      t.integer :material_id, null: false
      t.integer :laboratory_id, null: false
      t.decimal :calibration_factor, precision: 6, scale: 3 # Градуировочный коэфициент		
      t.decimal :aliquot_volume, precision: 5, scale: 2     # Объем аликвоты		
      t.decimal :solution_volume, precision: 5, scale: 2    # Объем раствора	
      t.decimal :sample_volume, precision: 5, scale: 2      # Объем отобраной пробы

      t.timestamps null: false
    end
  end
end
