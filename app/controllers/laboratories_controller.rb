class LaboratoriesController < ApplicationController
  def index
    @laboratories = Laboratory.all.order(:id)
  end
  
  def new
    @laboratory = Laboratory.new
  end
  
  def create
    @laboratory = Laboratory.new(laboratory_params)
    if @laboratory.save
      flash[:success] = "Создана лаборатория"
      redirect_to laboratories_path
    else
      render 'new'
    end
  end
  
  private
  
    def laboratory_params
      params.require(:laboratory).permit(:name) #, :calibration_factor, :aliquot_volume, :solution_volume, :sample_volume)
    end
end
