class RemoveTimestampTo < ActiveRecord::Migration
  def change
    remove_column :bulletins, :created_at
    remove_column :bulletins, :upeated_at
  end
end
