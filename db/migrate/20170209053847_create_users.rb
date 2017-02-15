class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :last_name
      t.string :first_name
      t.string :middle_name
      t.string :login
      t.string :password_digest
      t.string :position

      t.timestamps null: false
    end
    add_index :users, :login, unique: true
  end
end
