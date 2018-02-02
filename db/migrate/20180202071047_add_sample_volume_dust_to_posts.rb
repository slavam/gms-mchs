class AddSampleVolumeDustToPosts < ActiveRecord::Migration
  def change
    add_column(:posts, :sample_volume_dust, :decimal, precision: 7, scale: 2)
  end
end
