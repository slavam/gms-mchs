class AgroPhasesController < ApplicationController
  def index
    @agro_phases = AgroPhase.all.order(:agro_phase_category_id, :code)
  end
  
  def new
    @agro_phase = AgroPhase.new
  end
  
  def create
    @agro_phase = AgroPhase.new(agro_phase_params)
    if @agro_phase.save
      flash[:success] = "Создана фаза"
      redirect_to agro_phases_path
    else
      render 'new'
    end
  end
  
  private
    def agro_phase_params
      params.require(:agro_phase).permit(:name, :code, :agro_phase_category_id)
    end
end
