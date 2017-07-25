class Material < ActiveRecord::Base
  def Material.actual_materials
    Material.where("active = true")
  end
  # def self.actual_materials
  #   Material.find([1, 2, 4, 5, 6, 8, 10, 19, 22])
  # end
end
