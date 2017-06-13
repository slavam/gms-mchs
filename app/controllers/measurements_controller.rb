class MeasurementsController < ApplicationController
  before_filter :init_weather_params, :only => [:new]
  before_filter :find_measurement, only: [:destroy]
  TERMS = Array.new
  TERMS[1] = '00'
  TERMS[7] = '06'
  TERMS[13] = '12'
  TERMS[19] = '18'
  
  def get_convert_params
  end
  
  def convert_akiam
    date_from = params[:measurement][:date_from].to_s+' 00:00:00'
    date_to = params[:measurement][:date_to].to_s+' 23:59:59'
    source = Pollution.where("date >= '#{date_from}' AND date <= '#{date_to}'").order(:date, :idstation, :idsubstance)
    masters = Pollution.where("date >= '#{date_from}' AND date <= '#{date_to}'").select(:date, :idstation).group(:date, :idstation)
    write_count = 0
    values = {}
    
    masters.each do |m|
      measurement = Measurement.new
      measurement.date = m.date.to_date.to_s
      measurement.term = m.date.strftime("%H").to_i
      if m.idstation > 1
        measurement.post_id = m.idstation
        weather = get_weather(station_by_post(m.idstation.to_i), m.date.strftime("%Y.%m.%d"), TERMS[measurement.term])
        if weather.present?
          measurement[:wind_direction] = weather[:wind_direction]
          measurement[:rhumb] = wind_direction_to_rhumb(weather[:wind_direction])
          measurement[:wind_speed] = weather[:wind_speed]
          measurement[:temperature] = weather[:temperature]
          measurement[:atmosphere_pressure] = weather[:atmosphere_pressure]
          # measurement_save(measurement, values)
          # write_count += 1
          # Rails.logger.debug("My object: #{measurement.inspect}")
        end
      end
      akiam_date = source.select {|r| r.date == m.date.strftime("%Y.%m.%d %H") and r.idstation == m.idstation}
      akiam_date.each do |d|
        if d.idstation == 1
          case d.idsubstance
            when 103
              measurement.phenomena = d.value
            when 104
              measurement.relative_humidity = d.value
            when 105
              measurement.partial_pressure = d.value
          end
        else
          values[d.idsubstance] = d.value
        end
      end
      measurement_save(measurement, values) if m.idstation != 1
      Rails.logger.debug("My object: #{measurement.inspect}")
      Rails.logger.debug("My object: #{values.inspect}")
      write_count += 1
      values.clear
    end
    flash[:success] = "Входных записей - #{source.size}. Сохранено измерений - #{write_count}."
    redirect_to measurements_path

    # Rails.logger.debug("My object: #{masters.inspect}")
    
    # source_count = source.count
    # @record = nil
    # if source_count < 1
    #   flash[:success] = "Нет исходных данных в диапазоне с #{date_from} по #{date_to}"
    #   redirect_to measurements_path
    #   return
    # end
    # write_count = 0
    # date = '' #  source[0].date
    # post_id = 1
    # values = {}
    # measurement = Measurement.new
    # source.each do |d|
    #   @record = d
    #   if d.date == date
    #     if d.idstation == 1
    #       case d.idsubstance
    #         when 103
    #           measurement.phenomena = d.value
    #         when 104
    #           measurement.relative_humidity = d.value
    #         when 105
    #           measurement.partial_pressure = d.value
    #       end
    #     else
    #       if post_id == d.idstation
    #         values[d.idsubstance] = d.value
    #       elsif post_id == 1 
    #         measurement.date = d.date.to_date.to_s
    #         measurement.term = d.date.strftime("%H").to_i
    #         measurement.post_id = d.idstation
    #         post_id = d.idstation
    #         weather = get_weather(station_by_post(d.idstation.to_i), d.date.strftime("%Y.%m.%d"), TERMS[measurement.term])
    #         if weather.present?
    #           measurement[:wind_direction] = weather[:wind_direction]
    #           measurement[:rhumb] = wind_direction_to_rhumb(weather[:wind_direction])
    #           measurement[:wind_speed] = weather[:wind_speed]
    #           measurement[:temperature] = weather[:temperature]
    #           measurement[:atmosphere_pressure] = weather[:atmosphere_pressure]
    #           values[d.idsubstance] = d.value
    #           # measurement_save(measurement, values)
    #           write_count += 1
    #           Rails.logger.debug("My object: #{measurement.inspect}")
    #         else
    #           break
    #         end
    #       else
    #         measurement.post_id = d.idstation
    #         post_id = d.idstation
    #         # measurement_save(measurement, values)
    #         write_count += 1
    #         Rails.logger.debug("My object: #{measurement.inspect}")
    #         # measurement.clear
    #         values.clear
    #         values[d.idsubstance] = d.value
    #       end
    #     end
    #   else
    #     # measurement.date = d.date.to_date
    #     date = d.date
    #     post_id = 1
    #     # measurement.term = d.date.strftime("%H").to_i
    #     # weather = get_weather(@station, @date, @term)
    #     # station_by_post(post_id)
    #   end
    # end
    # # values[@record.idsubstance] = @record.value
    # # measurement_save(measurement, values)
  end

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
    measurement.rhumb = wind_direction_to_rhumb(measurement.wind_direction)
    values = params[:values]
    # Rails.logger.debug("My object: #{values.inspect}")
    if measurement_save(measurement, values)
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
    # terms = Array.new
    # terms[1] = '00'
    # terms[7] = '06'
    # terms[13] = '12'
    # terms[19] = '18'
    station = station_by_post(params[:post_id])
    synoptic_term = TERMS[params[:term].to_i]
    date = params[:date]
    weather = get_weather(station, date, synoptic_term)
    render json: {weather: weather}
  end
  
  private

    def measurement_save(measurement, values)
      ret = true
      if measurement.save
        if values.present? 
          values.each do |k, v|
            measurement.pollution_values.build(material_id: k.to_i, value: v.to_f).save
          end
        end
      else
        ret = false
      end
      return ret
    end
    
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
      # Rails.logger.debug("station: #{station.inspect}; date: #{date.inspect}; term: #{term}")
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
    
    def wind_direction_to_rhumb(wind_direction)
      case wind_direction
        when 0, 99
          'calm'
        when 5..13
          'east'
        when 14..22
          'south'
        when 23..31
          'west'
        else
          'north'
      end
    end
end
