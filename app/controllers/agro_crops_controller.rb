class AgroCropsController < ApplicationController
  def index
    @agro_crops = AgroCrop.all.order(:agro_crop_category_id, :code)
  end
  
  def new
    @agro_crop = AgroCrop.new
  end
  
  def create
    @agro_crop = AgroCrop.new(agro_crop_params)
    if @agro_crop.save
      flash[:success] = "Создана культура"
      redirect_to agro_crops_path
    else
      render 'new'
    end
  end
  
  private
    def agro_crop_params
      params.require(:agro_crop).permit(:name, :code, :agro_crop_category_id)
    end
end
