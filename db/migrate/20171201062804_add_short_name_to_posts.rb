class AddShortNameToPosts < ActiveRecord::Migration
  def change
    add_column(:posts, :short_name, :string)
  end
end
