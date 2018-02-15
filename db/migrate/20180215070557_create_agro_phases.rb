class CreateAgroPhases < ActiveRecord::Migration
  def change
    create_table :agro_phases do |t|
      t.references :agro_phase_category, :null => false
      t.integer :code
      t.string :name

      t.timestamps null: false
    end
  end
end
