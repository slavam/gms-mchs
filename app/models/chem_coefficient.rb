class ChemCoefficient < ActiveRecord::Base
  belongs_to :material
  belongs_to :laboratory
end
