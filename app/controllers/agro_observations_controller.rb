class AgroObservationsController < ApplicationController
  before_filter :find_agro_observation, only: [:show]
  
  def index
    @agro_observations = AgroObservation.paginate(page: params[:page]).order(:date_dev, :created_at).reverse_order
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
  
  def create_agro_telegram
    telegram = AgroObservation.new(agro_observation_params)
    telegram.station_id = Station.find_by_code(telegram.telegram[6,5].to_i).id
    telegram.telegram_type = telegram.telegram[0,5]
    telegram.day_obs = telegram.telegram[12,2].to_i
    telegram.month_obs = telegram.telegram[14,2].to_i
    telegram.telegram_num = telegram.telegram[16,1].to_i
    if telegram.save
      telegrams = AgroObservation.last_50_telegrams
      last_telegrams = fields_short_list(telegrams)
      render json: {telegrams: last_telegrams, tlgType: 'agro', currDate: telegram.date_dev, errors: ["Телеграмма добавлена в базу"]}
    else
      render json: {errors: telegram.errors.messages}, status: :unprocessable_entity
    end
  end
  
  private

    def agro_observation_params
      params.require(:agro_observation).permit(:telegram_type, :station_id, :date_dev, :day_obs, :month_obs, :telegram_num, :telegram)
    end
    
    def find_agro_observation
      @agro_observation = AgroObservation.find(params[:id])
    end
    
    def fields_short_list(full_list)
      full_list.map do |rec|
        {id: rec.id, date: rec.date_dev, station_name: rec.station.name, telegram: rec.telegram}
      end
    end
end
