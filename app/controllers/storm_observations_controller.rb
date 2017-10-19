class StormObservationsController < ApplicationController
  before_filter :find_storm_observation, only: [:show, :edit, :update, :destroy]
  def index
    @storm_observations = StormObservation.all.order(:created_at).reverse_order
  end
  
  def show
  end
  
  def new
    @storm_observation = StormObservation.new
  end
  
  def create
    @storm_observation = StormObservation.new(storm_observation_params)
    tlg_as_array = @storm_observation.telegram.split(' ')
    @storm_observation.day_event = tlg_as_array[3][0,2].to_i
    @storm_observation.hour_event = tlg_as_array[3][2,2].to_i if tlg_as_array[3][2,2] != '//'
    @storm_observation.minute_event = tlg_as_array[3][4,2].to_i if tlg_as_array[3][4,2] != '//'
    ret = true
    if @storm_observation.telegram_type != @storm_observation.telegram[0,5]
      flash[:danger] = 'Ошибка в типе телеграммы'
      ret = false
    end
    # для синоптиков шторм нужно сохранить и в синоптических 2017.09.28 
    # synoptic_telegram = SynopticObservation.new
    # synoptic_telegram.date = Time.now
    # synoptic_telegram.term = 25 # срок для штормов
    # synoptic_telegram.telegram = @storm_observation.telegram
    # synoptic_telegram.station_id = @storm_observation.station_id
    if ret and @storm_observation.save # and synoptic_telegram.save
      flash[:success] = "Создана штормовая телеграмма"
      redirect_to storm_observations_path
    else
      render 'new'
    end
  end
  
  def create_storm_telegram
    telegram = StormObservation.new(storm_observation_params)
    # telegram.station_id = Station.find_by_code(telegram.telegram[12,5].to_i).id
    # telegram.day_event = telegram.telegram[18,2].to_i
    telegram.hour_event = telegram.telegram[20,2].to_i
    telegram.minute_event = telegram.telegram[22,2].to_i
    telegram.telegram_type = telegram.telegram[0, 5]
    # Rails.logger.debug("My object>>>>>>>>>>>>>>>: #{telegram.inspect}")
    if telegram.save
      telegrams = StormObservation.last_50_telegrams
      last_telegrams = fields_short_list(telegrams)
      render json: {telegrams: last_telegrams, tlgType: 'storm', currDate: telegram.telegram_date, errors: ["Телеграмма добавлена в базу"]}
    else
      render json: {errors: telegram.errors.messages}, status: :unprocessable_entity
    end
  end
  
  def edit
  end
  
  def update
    if not @storm_observation.update_attributes storm_observation_params
      render :action => :edit
    else
      redirect_to storm_observations_path
    end
  end
  
  def destroy
    @storm_observation.destroy
    flash[:success] = "Удалена штормовая телеграмма"
    redirect_to storm_observations_path
  end
  
  private
    def storm_observation_params
      params.require(:storm_observation).permit(:registred_at, :telegram_type, :station_id, :day_event, :hour_event, :minute_event, :telegram, :telegram_date)
      # :code_warep, :wind_direction, :wind_speed_avg, :wind_speed_max
    end
    
    def find_storm_observation
      @storm_observation = StormObservation.find(params[:id])
    end
    
    def fields_short_list(full_list)
      # stations = Station.all
      full_list.map do |rec|
        {id: rec.id, date: rec.telegram_date, station_name: rec.station.name, telegram: rec.telegram}
      end
    end
end
