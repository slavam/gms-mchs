class AgroObservationsController < ApplicationController
  before_filter :find_agro_observation, only: [:show]
  
  def index
    @agro_observations = AgroObservation.all.order(:created_at).reverse_order
  end
  
  def show
  end
  
  def new
    @agro_observation = AgroObservation.new
    @agro_observation.date_dev = Time.now
  end
  
  def create
    @agro_observation = AgroObservation.new(agro_observation_params)
    tlg_as_array = @agro_observation.telegram.split(' ')
    @agro_observation.day_obs = tlg_as_array[2][0,2].to_i
    @agro_observation.month_obs = tlg_as_array[2][2,2].to_i
    # Rails.logger.debug("My object>>>>>>>>>>>>>>>: #{tlg_as_array.inspect}")
    ret = true
    if @agro_observation.telegram_type != @agro_observation.telegram[0,5]
      flash[:danger] = 'Ошибка в типе телеграммы'
      ret = false
    end
    if ret and @agro_observation.save
      flash[:success] = "Создана агро-телеграмма"
      redirect_to agro_observations_path
    else
      render 'new'
    end
  end
  
  private

    def agro_observation_params
      params.require(:agro_observation).permit(:telegram_type, :station_id, :date_dev, :day_obs, :month_obs, :telegram_num, :telegram)
    end
    
    def find_agro_observation
      @agro_observation = AgroObservation.find(params[:id])
    end
end
