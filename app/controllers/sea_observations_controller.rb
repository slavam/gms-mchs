class SeaObservationsController < ApplicationController
  before_filter :find_sea_observation, only: [:show, :update_sea_telegram] #, :edit, :update, :destroy]
  
  def index
    @sea_observations = SeaObservation.paginate(page: params[:page]).order(:date_dev, :created_at).reverse_order
  end

  def show
  end
  
  def input_sea_telegrams
    @stations = Station.all.order(:name)
    @telegrams = SeaObservation.short_last_50_telegrams
  end
  
  def create_sea_telegram
    telegram = SeaObservation.new(sea_observation_params)
    telegram.station_id = 10 # Только Седово
    telegram.day_obs = telegram.telegram[5,2].to_i
    telegram.term = telegram.telegram[7,2].to_i
    # Rails.logger.debug("My object>>>>>>>>>>>>>>>: #{telegram.inspect}")
    if telegram.save
      last_telegrams = SeaObservation.short_last_50_telegrams
      render json: {telegrams: last_telegrams, tlgType: 'sea', currDate: telegram.date_dev, errors: ["Телеграмма добавлена в базу"]}
    else
      render json: {errors: telegram.errors.messages}, status: :unprocessable_entity
    end
  end
  
  def update_sea_telegram
    if @sea_observation.update_attributes sea_observation_params
      render json: {errors: []}
    else
      render json: {errors: ["Ошибка при сохранении изменений"]}, status: :unprocessable_entity
    end
  end
  
  def get_last_telegrams
    telegrams = SeaObservation.short_last_50_telegrams
    render json: {telegrams: telegrams, tlgType: 'sea'}
  end
  
  private
    def find_sea_observation
      @sea_observation = SeaObservation.find(params[:id])
    end
    def sea_observation_params
      params.require(:sea_observation).permit(:term, :telegram, :station_id, :day_obs, :date_dev)
    end
    def fields_short_list(full_list)
      full_list.map do |rec|
        {id: rec.id, date: rec.date_dev, station_name: rec.station.name, telegram: rec.telegram}
      end
    end
end
