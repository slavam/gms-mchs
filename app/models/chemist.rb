class Chemist < ActiveRecord::Base
  establish_connection :chemist
  self.abstract_class = true
end