class AddLabratoryIdToPosts < ActiveRecord::Migration
  def change
    add_column(:posts, :laboratory_id, :integer)
  end
end
