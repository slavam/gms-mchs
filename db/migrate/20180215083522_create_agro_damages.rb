class CreateAgroDamages < ActiveRecord::Migration
  def change
    create_table :agro_damages do |t|
      t.integer :code
      t.string :name

      t.timestamps null: false
    end
  end
end
