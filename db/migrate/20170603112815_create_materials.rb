class CreateMaterials < ActiveRecord::Migration
  def change
    create_table :materials do |t|
      t.string :name
      t.string :unit
      t.float :pdksr
      t.float :pdkmax
      t.float :vesmn
      t.float :klop
      t.float :imax
      t.integer :v
      t.float :grad
      t.integer :point

      t.timestamps null: false
    end
  end
end
