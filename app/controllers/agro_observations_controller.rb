class AgroObservationsController < ApplicationController
  def new
    @agro_observaton = AgroObsevation.new
  end
  
  private

    def agro_observaton_params
      params.require(:agro_observaton).permit(:telegram_type, :station_id, :date_dev, :day_obs, :month_obs, :telegram_num, :telegram)
    end
    
    def find_agro_observation
      @agro_observaton = AgroObsevation.find(params[:id])
    end
end
