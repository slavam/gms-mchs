class SeaObservationsController < ApplicationController
  before_filter :find_sea_observation, only: [:show] #, :edit, :update, :destroy]
  
  def index
    @sea_observations = SeaObservation.paginate(page: params[:page]).order(:date_dev, :created_at).reverse_order
  end

  def show
  end
  
  def create_sea_telegram
    telegram = SeaObservation.new(sea_observation_params)
    telegram.station_id = 10 # Только Седово
    telegram.day_obs = telegram.telegram[5,2].to_i
    telegram.term = telegram.telegram[7,2].to_i
    # Rails.logger.debug("My object>>>>>>>>>>>>>>>: #{telegram.inspect}")
    if telegram.save
      telegrams = SeaObservation.last_50_telegrams
      last_telegrams = fields_short_list(telegrams)
      render json: {telegrams: last_telegrams, tlgType: 'sea', currDate: telegram.date_dev, errors: ["Телеграмма добавлена в базу"]}
    else
      render json: {errors: telegram.errors.messages}, status: :unprocessable_entity
    end
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
