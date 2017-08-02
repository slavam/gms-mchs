class Pollution < Chemist
  self.table_name = "dimension"
  belongs_to :akiam_station, foreign_key: "idstation"
  belongs_to :substance, foreign_key: "idsubstance" 
end