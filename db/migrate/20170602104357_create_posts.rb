class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.integer :city_id
      t.integer :site_type_id
      t.string  :name
      t.integer :substances_num
      t.integer :coordinates
      t.integer :coordinates_sign
      t.integer :vd
      t.integer :height

      t.timestamps null: false
    end
  end
end
