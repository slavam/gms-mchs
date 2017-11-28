class PostsController < ApplicationController
  before_filter :find_post, only: [:edit, :update]
  
  def edit
  end  
  
  def update
    if not @post.update_attributes post_params
      render :action => :edit
    else
      redirect_to posts_path
    end
  end
  
  def index
    @posts = Post.all.order(:id)
  end

  private
    def post_params
      params.require(:post).permit(:site_type_id, :name, :substances_num, :coordinates, :coordinates_sign, :vd, :height, :active, :laboratory_id)
    end
    
    def find_post
      @post = Post.find(params[:id])
    end
end
