class MaterialsController < ApplicationController
  before_filter :find_material, only: [:edit, :update]
  def edit
  end  
  
  def update
    if not @material.update_attributes material_params
      render :action => :edit
    else
      redirect_to materials_path
    end
  end
  
  def index
    @materials = Material.all.order(:id)
  end
  
  private
    def material_params
      params.require(:material).permit(:name, :unit, :pdksr, :pdkmax, :vesmn, :klop, :imax, :v, :grad, :point, :active)
    end
    
    def find_material
      @material = Material.find(params[:id])
    end
end
