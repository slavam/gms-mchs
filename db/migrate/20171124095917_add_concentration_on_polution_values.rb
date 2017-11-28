class AddConcentrationOnPolutionValues < ActiveRecord::Migration
  def change
    add_column(:pollution_values, :concentration, :float)
  end
end
