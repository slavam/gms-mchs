class AddBulletinTypeToBulletins < ActiveRecord::Migration
  def change
    add_column(:bulletins, :bulletin_type, :string, default: 'daily')
  end
end
