class Post < ActiveRecord::Base
  belongs_to :city
  belongs_to :site_type
end
