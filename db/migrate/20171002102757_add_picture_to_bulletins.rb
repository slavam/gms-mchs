class AddPictureToBulletins < ActiveRecord::Migration
  def change
    add_column :bulletins, :picture, :string
  end
end
