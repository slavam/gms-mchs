class CreateApplicants < ActiveRecord::Migration
  def change
    create_table :applicants do |t|
      t.text :telegram

      t.timestamps null: false
    end
  end
end
