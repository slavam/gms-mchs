class MeasurementsController < ApplicationController
  before_filter :init_weather_params, :only => [:new]
  def new
    @date = '2017.01.03'
    @weather = get_weather(@station, @date, @term)
    @measurement = Measurement.new
  end
  
  def create
    @measurement = Measurement.new(user_params)
    if @measurement.save
      # pollution_values = params[:pollution_values]
      flash[:success] = "Измерения сохранены"
      redirect_to @user
    else
      render 'new'
    end
  end
  
  private
    def init_weather_params
      @station ||= '34519' # Донецк
      @date ||= Time.now.to_s(:custom_datetime)
      @term ||= '06'
    end
    
    def get_weather(station, date, term)
      weather = {}
      telegram = Synoptic.where("Дата like ? and Срок = ? and (Телеграмма like 'ЩЭСМЮ #{station} %' or Телеграмма like 'ЩЭСИД #{station} %')", date+'%', term)[0]
      weather[:wind_speed] = telegram.wind_speed
      weather[:wind_direction] = telegram.get_wind_direction
      weather[:rhumb] = telegram.get_rhumb_4
      weather[:temperature] = telegram.get_temperature
      weather[:atmosphere_pressure] = telegram.get_pressure
      return weather
    end
end
