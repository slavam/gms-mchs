class MeasurementsController < ApplicationController
  before_filter :init_weather_params, :only => [:new]
  before_filter :find_measurement, only: [:destroy]
  
  def index
    @measurements = Measurement.paginate(page: params[:page]).order(:date).reverse_order.order(:term).order(:post_id)
  end
  
  def new
    @date = '2017.01.03'
    @weather = get_weather(@station, @date, @term)
    @materials = Material.actual_materials
    @posts = Post.all.order(:id)
    @post_id = 14
    @measurement = Measurement.new
  end
  
  def save_pollutions # create
    measurement = Measurement.new(measurement_params)
    # measurement = Measurement.new(params[:measurement])
    values = params[:values]
    Rails.logger.debug("My object: #{values.inspect}")
    # redirect_to measurements_path
    if measurement.save
      values.each do |k, v|
        measurement.pollution_values.build(material_id: k.to_i, value: v.to_f).save
      end
      flash[:success] = "Измерения сохранены"
      redirect_to measurements_path
    else
      render 'new'
    end
  end

  def destroy
    @measurement.destroy
    flash[:success] = "Измерение удалено"
    redirect_to measurements_path
  end
  
  def station_by_post(post_id)
    if post_id.to_i < 15
        '34519' # Донецк
      else
        '34510' # Артемовск
    end
  end
  
  def weather_update
    terms = Array.new
    terms[1] = '00'
    terms[7] = '06'
    terms[13] = '12'
    terms[19] = '18'
    station = station_by_post(params[:post_id])
    synoptic_term = terms[params[:term].to_i]
    date = params[:date]
    weather = get_weather(station, date, synoptic_term)
    render json: {weather: weather}
  end
  
  private
    def find_measurement
      @measurement = Measurement.find(params[:id])
    end
    
    def measurement_params
      params.require(:measurement).permit(:post_id, :date, :term, :rhumb, :wind_direction,  :wind_speed, :temperature, :phenomena, :relative_humidity, :partial_pressure, :atmosphere_pressure)
      # params.permit(:post_id, :date, :term, :rhumb, :wind_direction,  :wind_speed, :temperature, :phenomena, :relative_humidity, :partial_pressure, :atmosphere_pressure, :values)
    end
    def init_weather_params
      @station ||= '34519' # Донецк
      @date ||= Time.now.to_s(:custom_datetime)
      @term ||= '06'
    end
    
    def get_weather(station, date, term)
      weather = {}
      telegram = Synoptic.where("Дата like ? and Срок = ? and (Телеграмма like 'ЩЭСМЮ #{station} %' or Телеграмма like 'ЩЭСИД #{station} %')", date+'%', term)[0]
      return nil if telegram.nil?
      weather[:wind_speed] = telegram.wind_speed
      weather[:wind_direction] = telegram.get_wind_direction
      weather[:rhumb] = telegram.get_rhumb_4
      weather[:temperature] = telegram.get_temperature
      weather[:atmosphere_pressure] = telegram.get_pressure
      return weather
    end
end
