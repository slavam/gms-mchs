class Material < ActiveRecord::Base
  def self.actual_materials
    Material.find([1, 2, 3, 4, 5, 6, 8, 10, 19, 22])
  end
end
