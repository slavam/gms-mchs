class AddStationReferenceToUsers < ActiveRecord::Migration
  def change
    add_reference :users, :station, index: true, foreign_key: true
  end
end
