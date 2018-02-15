class AgroCropCategoriesController < ApplicationController
  def index
    @agro_crop_categories = AgroCropCategory.all.order(:id)
  end
  
  def new
    @agro_crop_category = AgroCropCategory.new
  end
  
  def create
    @agro_crop_category = AgroCropCategory.new(agro_crop_category_params)
    if @agro_crop_category.save
      flash[:success] = "Создана категория культур"
      redirect_to agro_crop_categories_path
    else
      render 'new'
    end
  end
  
  private
    def agro_crop_category_params
      params.require(:agro_crop_category).permit(:name)
    end
end
