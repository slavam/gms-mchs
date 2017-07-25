class AddActiveToMaterials < ActiveRecord::Migration
  def change
    add_column(:materials, :active, :boolean)
  end
end
