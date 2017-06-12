class Measurement < ActiveRecord::Base
  belongs_to :post
  has_many :pollution_values, :dependent => :destroy
end
