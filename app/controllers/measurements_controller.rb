require 'descriptive_statistics'
class MeasurementsController < ApplicationController
  before_filter :init_weather_params, :only => [:new]
  before_filter :find_measurement, only: [:destroy]
  HAZARD_CLASS =Array.new
  HAZARD_CLASS[1] = 1.7
  HAZARD_CLASS[2] = 1.3
  HAZARD_CLASS[3] = 1.0
  HAZARD_CLASS[4] = 0.9
  TERMS = Array.new
  TERMS[1] = '00'
  TERMS[7] = '06'
  TERMS[13] = '12'
  TERMS[19] = '18'

  def print_forma2
    @date_from = params[:date_from]
    @date_to = params[:date_to]
    @scope_name = get_place_name(params[:region_type], params[:place_id])
    pollutions = get_data_forma2(@date_from, @date_to, params[:region_type], params[:place_id]) #post_id, city_id)
    @total_materials = pollutions.size
    header0 = [{content: "Код", rowspan: 2}, 
      {content: "Название", rowspan: 2},
      {content: "Число замеров", rowspan: 2, rotate: 90},
      {content: "Средняя концентрация", rowspan: 2, rotate: 90},
      {content: "Максимальная концентрация", colspan: 4 }, 
      {content: "Среднеквадратичное отклонение", rowspan: 2, rotate: 90},
      {content: "Коэффициент вариации", rowspan: 2, rotate: 90},
      {content: "Процент повторяемости", colspan: 3}, 
      {content: "Количество случаев превышения", colspan: 3}, 
      {content: "ИЗА", rowspan: 2}, 
      {content: "Средняя концентрация в ПДКср", rowspan: 2, rotate: 90}, 
      {content: "Максимальная концентрация в ПДКмакс", rowspan: 2, rotate: 90}]
    header1 = ["Значение", "Пост", "Дата", "Срок","1ПДК","5ПДК", "10ПДК", "1ПДК","5ПДК", "10ПДК"]
    @pollutions = []
    @pollutions << header0
    @pollutions << header1
    @total_pollutions = 0
    pollutions.each do |k,p|
      @pollutions << make_row(k, p)
      @total_pollutions += p[:size]
    end
    # Rails.logger.debug("My object: #{@pollutions.inspect}")
  end
  
  def chem_forma2
    @date_from = '2016-02-01' # Time.now.strftime("%Y-%m-01")
    @date_to = '2016-02-29' # Time.now.strftime("%Y-%m-%d")
    @region_type = params[:region_type] #'post' # total, city
    @place_id = params[:place_id]
    @scope_name = get_place_name(params[:region_type], params[:place_id])
    if @region_type == 'post'
      @posts = Post.where("name != 'Резерв'").order(:city_id, :id)
    else
      @cities = City.all.order(:id)
    end
    @pollutions = get_data_forma2(@date_from, @date_to, @region_type, @place_id) # post_id, city_id)
  end
  
  def get_chem_forma2_data
    scope_name = get_place_name(params[:region_type], params[:place_id])
    pollutions = get_data_forma2(params[:date_from], params[:date_to], params[:region_type], params[:place_id]) # post_id, city_id)
    
    render json: {pollutions: pollutions, dateFrom: params[:date_from], dateTo: params[:date_to], scopeName: scope_name}
  end
  
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
      # Rails.logger.debug("My object: #{measurement.inspect}")
      # Rails.logger.debug("My object: #{values.inspect}")
      write_count += 1
      values.clear
    end
    flash[:success] = "Входных записей - #{source.size}. Сохранено измерений - #{write_count}."
    redirect_to measurements_path

  end

  def index
    @measurements = Measurement.paginate(page: params[:page]).order(:date).reverse_order.order(:term).order(:post_id)
  end
  
  def new
    @date = '2017-01-03'
    @weather = get_weather(@station, @date, @term)
    @materials = Material.actual_materials
    @posts = Post.all.order(:id)
    @post_id = 14
    measurement_id = Measurement.get_id_by_date_term_post(@date, 7, @post_id)
    @concentrations = []
    if measurement_id.present?
      @concentrations = get_concentrations_by_measurement(measurement_id)
    end
  end
  
  def save_pollutions # create
    measurement = Measurement.new(measurement_params)
    measurement.rhumb = wind_direction_to_rhumb(measurement.wind_direction)
    values = params[:values]
    Rails.logger.debug("My object: #{measurement.inspect}")
    if measurement.save
      if values.present? 
        values.each do |k, v|
          measurement.pollution_values.build(material_id: k.to_i, value: v.to_f).save
        end
      end
      flash[:success] = "Измерения сохранены"
      redirect_to measurements_path
    else
      # render 'new'
      # Rails.logger.debug("My object: #{measurement.errors.messages.inspect}")
      # render :json => { :errors =>measurement.errors.messages }, :status => 422
    end
    # Rails.logger.debug("My object: #{values.inspect}")
    # if measurement_save(measurement, values)
    #   flash[:success] = "Измерения сохранены"
    #   redirect_to measurements_path
    # else
    #   # render :json => { :errors => @employee.errors.messages }, :status => 422
    #   Rails.logger.debug("My object: #{values.inspect}")
    #   render json: {errors: {code: "Error"}}
    #   # render 'new'
    # end
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
    station = station_by_post(params[:post_id])
    synoptic_term = TERMS[params[:term].to_i]
    date = params[:date]
    weather = get_weather(station, date, synoptic_term)
    err = weather.nil? ? "В базе не найдена погода для поста: #{params[:post_id]}, дата: #{params[:date]}, срок: #{params[:term]}" : ''
    if weather.present?
      # measurements = Measurement.where("date = ? AND term = ? AND post_id = ?", date, params[:term], params[:post_id])
      # measurement_id = measurements[0].id if measurements.size > 0
      measurement_id = Measurement.get_id_by_date_term_post(date, params[:term], params[:post_id])
      concentrations = []
      if measurement_id.present?
        concentrations = get_concentrations_by_measurement(measurement_id)
      end
    end
    render json: {weather: weather, errors: [err], concentrations: concentrations}
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
      params.require(:measurement).permit(:region_type, :post_id, :date, :term, :rhumb, :wind_direction,  :wind_speed, :temperature, :phenomena, :relative_humidity, :partial_pressure, :atmosphere_pressure)
      # params.permit(:region_type, :post_id, :date, :term, :rhumb, :wind_direction,  :wind_speed, :temperature, :phenomena, :relative_humidity, :partial_pressure, :atmosphere_pressure)
    end
    
    def init_weather_params
      @station ||= '34519' # Донецк
      @date ||= Time.now.to_s(:custom_datetime)
      @term ||= '06'
    end
    
    def get_weather(station, date, term)
      # Rails.logger.debug("station: #{station.inspect}; date: #{date.inspect}; term: #{term}")
      synoptic_date = date.gsub('-','.')
      weather = {}
      telegram = Synoptic.where("Дата like ? and Срок = ? and (Телеграмма like 'ЩЭСМЮ #{station} %' or Телеграмма like 'ЩЭСИД #{station} %')", synoptic_date+'%', term)[0]
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
    
    def make_row(k, v)
      row = []
      row[0] = k
      row[1] = {content: v[:material_name]}
      row[2] = v[:size]
      row[3] = v[:mean]
      row[4] = v[:max_concentration][:value]
      row[5] = v[:max_concentration][:post_id]
      row[6] = v[:max_concentration][:date]
      row[7] = v[:max_concentration][:term]
      row[8] = v[:standard_deviation]
      row[9] = v[:variance]
      row[10] = v[:percent1]
      row[11] = v[:percent5]
      row[12] = v[:percent10]
      row[13] = v[:lt_1pdk]
      row[14] = v[:lt_5pdk]
      row[15] = v[:lt_10pdk]
      row[16] = v[:pollution_index]
      row[17] = v[:avg_conc]
      row[18] = v[:max_conc]
      return row
    end

    def get_data_forma2(date_from, date_to, region_type, place_id) # post_id, city_id)
      case region_type
        when 'total'
          pollutions = Pollution.where("date >= ? AND date <= ?", date_from, date_to)
        when 'post'
          pollutions = PollutionValue.find_by_sql("SELECT * FROM pollution_values p_v INNER JOIN measurements m ON m.id = p_v.measurement_id AND m.date >= '#{date_from}' AND m.date <= '#{date_to}' AND m.post_id = #{place_id} INNER JOIN materials ma ON ma.id = p_v.material_id order by p_v.material_id")
        else
          pollutions = PollutionValue.find_by_sql("SELECT * FROM pollution_values p_v INNER JOIN measurements m ON m.id = p_v.measurement_id AND m.date >= '#{date_from}' AND m.date <= '#{date_to}' INNER JOIN materials ma ON ma.id = p_v.material_id INNER JOIN posts p on p.id=m.post_id AND p.city_id=#{place_id} order by p_v.material_id")
      end
      by_materials = {}
      concentrations = {}
      material_ids = []
      pollutions.each do |p|
        if by_materials[p.material_id].nil?
          material_ids << p.material_id
          concentrations[p.material_id] = {values: []}
          by_materials[p.material_id] = {max_concentration: {value: 0, post_id: 0, date: nil, term: nil}, size: 0, mean: 0, standard_deviation: 0, variance: 0, pollution_index: 0.0, material_name: p.material.name, hazard_index: p.material.klop.to_i, pdk_avg: p.material.pdksr, pdk_max: p.material.pdkmax, lt_1pdk: 0, lt_5pdk: 0, lt_10pdk: 0, percent1: 0.0, percent5: 0.0, percent10: 0.0, avg_conc: 0.0, max_conc: 0.0}
        end
        concentrations[p.material_id][:values] << p.value
        by_materials[p.material_id][:lt_1pdk] += 1 if p.value > by_materials[p.material_id][:pdk_max]
        by_materials[p.material_id][:lt_5pdk] += 1 if p.value > by_materials[p.material_id][:pdk_max]*5
        by_materials[p.material_id][:lt_10pdk] += 1 if p.value > by_materials[p.material_id][:pdk_max]*10
        if by_materials[p.material_id][:max_concentration][:value] < p.value
          by_materials[p.material_id][:max_concentration][:value] = p.value.round(4) 
          by_materials[p.material_id][:max_concentration][:post_id] = p.post_id
          by_materials[p.material_id][:max_concentration][:date] = p.date
          by_materials[p.material_id][:max_concentration][:term] = p.term
        end
      end
      material_ids.each do |m|
        by_materials[m][:size] = concentrations[m][:values].size
        by_materials[m][:mean] = concentrations[m][:values].mean.round(4)
        by_materials[m][:standard_deviation] = concentrations[m][:values].standard_deviation.round(4)
        by_materials[m][:variance] = (by_materials[m][:standard_deviation]/by_materials[m][:mean]).round(4) if by_materials[m][:mean] > 0
        by_materials[m][:percent1] = (by_materials[m][:lt_1pdk]/by_materials[m][:size].to_f*100.0).round(2)
        by_materials[m][:percent5] = (by_materials[m][:lt_5pdk]/by_materials[m][:size].to_f*100.0).round(2)
        by_materials[m][:percent10] = (by_materials[m][:lt_10pdk]/by_materials[m][:size].to_f*100.0).round(2)
        by_materials[m][:pollution_index] = ((by_materials[m][:mean]/by_materials[m][:pdk_avg])**HAZARD_CLASS[by_materials[m][:hazard_index]]).round(4)
        by_materials[m][:avg_conc] = (by_materials[m][:mean]/by_materials[m][:pdk_avg]).round(4)
        by_materials[m][:max_conc] = (by_materials[m][:max_concentration][:value]/by_materials[m][:pdk_max]).round(4)
      end
      return by_materials
    end
    
    def get_concentrations_by_measurement(measurement_id)
      # return PollutionValue.where("measurement_id = ?", measurement_id).order(:material_id)
      pollutions = PollutionValue.find_by_sql("SELECT p_v.id id, p_v.material_id material_id, p_v.value value, ma.name name FROM pollution_values p_v INNER JOIN materials ma ON ma.id = p_v.material_id WHERE p_v.measurement_id = #{measurement_id} ORDER BY p_v.material_id")
# Rails.logger.debug("My object: #{pollutions.inspect}")
      concentrations = {}
      pollutions.each {|p|
        concentrations[p.material_id] = {id: p.id, material_name: p.name, value: p.value}
      }
      return concentrations
    end
    
    def get_place_name(region_type, place_id)
      if region_type == 'post`'
        ret = Post.find(place_id).name
      else
        ret = City.find(place_id).name
      end
      return ret
    end

end
