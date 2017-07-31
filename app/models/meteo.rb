class Meteo < ActiveRecord::Base
  establish_connection :meteo
  self.abstract_class = true
end