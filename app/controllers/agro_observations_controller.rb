class AgroObservationsController < ApplicationController
  before_filter :find_agro_observation, only: [:show, :update_agro_telegram]
  
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
    telegram_text = params[:agro_observation][:telegram]
    station_id = params[:agro_observation][:station_id]
    date_dev = params[:input_mode] == 'direct' ? Time.parse(params[:date]+' 00:01:00') : Time.now
    telegram_type = telegram_text[0,5]
    day_obs = telegram_text[12,2].to_i
    month_obs = telegram_text[14,2].to_i
    telegram_num = telegram_text[16,1].to_i

    telegram = AgroObservation.find_by( station_id: station_id, 
                                        telegram_type: telegram_type, 
                                        day_obs: day_obs, 
                                        month_obs: month_obs, 
                                        telegram_num: telegram_num)
    if telegram.present?
      if telegram.update_attributes agro_observation_params
        last_telegrams = AgroObservation.short_last_50_telegrams
        render json: {telegrams: last_telegrams, 
                      tlgType: 'agro', 
                      inputMode: params[:input_mode],
                      currDate: date_dev, 
                      errors: ["Телеграмма изменена"]}
      else
        render json: {errors: telegram.errors.messages}, status: :unprocessable_entity
      end
    else
      telegram = AgroObservation.new(agro_observation_params)
      telegram.date_dev = date_dev
      telegram.telegram_type = telegram_type
      telegram.day_obs = day_obs
      telegram.month_obs = month_obs
      telegram.telegram_num = telegram_num
      telegram.telegram = telegram_text
      if telegram.save
        last_telegrams = AgroObservation.short_last_50_telegrams
        render json: {telegrams: last_telegrams, 
                      tlgType: 'agro', 
                      inputMode: params[:input_mode],
                      currDate: date_dev, 
                      errors: ["Телеграмма добавлена в базу"]}
      else
        render json: {errors: telegram.errors.messages}, status: :unprocessable_entity
      end
    end
  end
  
  def input_agro_telegrams
    @stations = Station.all.order(:name)
    @telegrams = AgroObservation.short_last_50_telegrams
  end
  
  def get_last_telegrams
    telegrams = AgroObservation.short_last_50_telegrams
    render json: {telegrams: telegrams, tlgType: 'agro'}
  end
  
  def update_agro_telegram
    if @agro_observation.update_attributes agro_observation_params
      render json: {errors: []}
    else
      render json: {errors: ["Ошибка при сохранении изменений"]}, status: :unprocessable_entity
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
