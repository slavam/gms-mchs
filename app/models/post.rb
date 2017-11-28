class Post < ActiveRecord::Base
  belongs_to :city
  belongs_to :laboratory
  belongs_to :site_type
  
  def Post.actual
    Post.where("active = true")
  end
end
