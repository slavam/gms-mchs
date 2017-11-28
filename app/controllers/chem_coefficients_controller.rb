class ChemCoefficientsController < ApplicationController
  before_filter :find_chem_coefficient, only: [:edit, :update, :destroy]
  
  def index
    @chem_coefficients = ChemCoefficient.all.order(:laboratory_id, :material_id)
  end
  
  def new
    @chem_coefficient = ChemCoefficient.new
  end
  
  def create
    @chem_coefficient = ChemCoefficient.new(chem_coefficient_params)
    if @chem_coefficient.save
      flash[:success] = "Создан набор коэффициентов"
      redirect_to chem_coefficients_path
    else
      render 'new'
    end
  end
  
  def edit
  end
  
  def update
    if not @chem_coefficient.update_attributes chem_coefficient_params
      render :action => :edit
    else
      redirect_to chem_coefficients_path
    end
  end
  
  def destroy
    @chem_coefficient.destroy
    flash[:success] = "Запись удалена"
    redirect_to chem_coefficients_path
  end
  
  private
    def find_chem_coefficient
      @chem_coefficient = ChemCoefficient.find(params[:id])
    end
  
    def chem_coefficient_params
      params.require(:chem_coefficient).permit(:material_id, :laboratory_id, :calibration_factor, :aliquot_volume, :solution_volume, :sample_volume)
    end
end
