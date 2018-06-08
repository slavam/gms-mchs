class AddTypeMessageToApplicants < ActiveRecord::Migration
  def change
    add_column(:applicants, :message, :string)
    add_column(:applicants, :telegram_type, :string)
  end
end
