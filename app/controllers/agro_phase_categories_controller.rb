class AgroPhaseCategoriesController < ApplicationController
  def index
    @agro_phase_categories = AgroPhaseCategory.all.order(:id)
  end
  
  def new
    @agro_phase_category = AgroPhaseCategory.new
  end
  
  def create
    @agro_phase_category = AgroPhaseCategory.new(agro_phase_category_params)
    if @agro_phase_category.save
      flash[:success] = "Создана группа культур"
      redirect_to agro_phase_categories_path
    else
      render 'new'
    end
  end
  
  private
    def agro_phase_category_params
      params.require(:agro_phase_category).permit(:name)
    end
end
