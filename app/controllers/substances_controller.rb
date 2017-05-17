class SubstancesController < ApplicationController
  before_filter :find_substance, only: [:show, :edit, :update]
  def edit
  end

  def update
    if not @substance.update_attributes substance_params
      render :action => :edit
    else
      redirect_to substances_path
    end
  end

  def index
    @substances = Substance.all
  end

  def show
  end
  
  private
    def substance_params
      params.require(:substance).permit(:description, :edval, :pdksr, :pdkmax, :vesmn, :klop, :imax, :v, :grad, :point)
    end
    
    def find_substance
      @substance = Substance.find(params[:id])
    end
end
