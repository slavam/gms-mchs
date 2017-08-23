class AddSummerToBulletins < ActiveRecord::Migration
  def change
    add_column(:bulletins, :summer, :boolean, default: false)
  end
end
