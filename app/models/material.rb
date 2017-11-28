class Material < ActiveRecord::Base
  def Material.actual_materials
    Material.where("active = true")
  end
end
