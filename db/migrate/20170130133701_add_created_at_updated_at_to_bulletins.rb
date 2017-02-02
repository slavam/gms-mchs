class AddCreatedAtUpdatedAtToBulletins < ActiveRecord::Migration
  def change
    add_column :bulletins, :created_at, :datetime, default: Time.now, null: false
    add_column :bulletins, :upeated_at, :datetime, default: Time.now, null: false
  end
end
