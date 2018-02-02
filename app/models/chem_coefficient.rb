class ChemCoefficient < ActiveRecord::Base
  belongs_to :material
  belongs_to :laboratory
  # Донецк:
  # №5 2200
  # №7 2200
  # №9 2000
  # 14 2200
  # Макеевка
  # 12 2200
  # 13 2200
  
  
end
