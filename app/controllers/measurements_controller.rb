require 'descriptive_statistics'
class MeasurementsController < ApplicationController
  before_filter :require_chemist
  # before_filter :init_weather_params, :only => [:new]
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

  def chem_forma1_tza
    @year = '2016' #@pollution_date_end.year.to_s #'2005' 
    @month = '01' #month_mm
    @post_id =  5 # 20 for Gorlovka
    @matrix = get_matrix_data(@year, @month, @post_id)
    @posts = Post.actual.order(:id) 
  end

  def get_chem_forma1_tza_data
    month = params[:month]
    year = params[:year]
    post_id = params[:post_id]
    matrix = get_matrix_data(year, month, post_id)
    render json: {year: year, month: month, matrix: matrix, postId: post_id}
  end

  def make_forma1_row(k, ps)
    row = []
    row[0] = k[0,10]
    row[1] = k[11,2]
    ps.each {|v| row << v[1]}
    return row
  end
  
  def print_forma1_tza
    @year = params[:year]
    @month = params[:month]
    @post_id = params[:post_id]
    @matrix = get_matrix_data(@year, @month, @post_id)
    header0 = ["<b>Дата</b>", "<b>Срок</b>"]
    @matrix[:substance_names].each {|h| header0 << "<b>#{h[1]}</b> мг/м<sup>3</sup>"}
    @pollutions = []
    @pollutions << header0
    @matrix[:pollutions].each do |k, p|
      @pollutions << make_forma1_row(k, p)
    end
    @pollutions << ["<b>Число измерений</b>", ""] + @matrix[:measure_num].map{|k,v| v}
    @pollutions << ["<b>Среднее</b>", ""] + @matrix[:avg_values].map{|k,v| v}
    @pollutions << ["<b>Максимум</b>", ""] + @matrix[:max_values].map{|k,v| v}
  end
  
  def print_forma2
    @date_from = params[:date_from]
    @date_to = params[:date_to]
    @scope_name = get_place_name(params[:region_type], params[:place_id])
    pollutions = get_data_forma2(@date_from, @date_to, params[:region_type], params[:place_id]) 
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
      @posts = Post.actual.order(:city_id, :id) 
    else
      @cities = City.all.order(:id)
    end
    @pollutions = get_data_forma2(@date_from, @date_to, @region_type, @place_id) 
  end
  
  def get_chem_forma2_data
    scope_name = get_place_name(params[:region_type], params[:place_id])
    pollutions = get_data_forma2(params[:date_from], params[:date_to], params[:region_type], params[:place_id]) 
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
    @date_loc = (Time.now.utc+3.hours).strftime("%Y-%m-%d")
    @date_utc = Time.now.utc.strftime("%Y-%m-%d")
    @post_id = 14 # for example
    @chem_term = ((Time.now.utc + 3.hours).hour / 6) * 6 + 1
    syn_term = @chem_term == 1 ? 21 : @chem_term-4
    # term = 3 # ((Time.now + 3.hours).hour / 6) * 6 # (Time.now.utc.hour/3*3).to_s.rjust(2, '0')
    @materials = Material.actual_materials
    @posts = Post.actual.order(:id)
    
    measurement = Measurement.find_by(date: @date_loc, term: @chem_term, post_id: @post_id)
    
    if measurement.present?
      @concentrations = get_concentrations_by_measurement(measurement.id)
      @weather = measurement.get_weather
    else
      @concentrations = []
      @weather = get_weather_from_synoptic_observatios(@post_id, @date_utc, syn_term)
    end
  end
  
  def save_pollutions # create
    measurement = Measurement.new(measurement_params)
    measurement.rhumb = wind_direction_to_rhumb(measurement.wind_direction)
    values = params[:values]
    # Rails.logger.debug("My object: #{measurement.inspect}")
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
  end

  def write_pollutions(measurement, pollutions)
    pollutions.each do |k, v|
      PollutionValue.where("measurement_id = ? AND material_id = ?", measurement.id, k).first_or_initialize.tap do |pollution|
        pollution.measurement_id = measurement.id
        pollution.material_id = k.to_i
        pollution.value = v.to_f
        # Rails.logger.debug("My object>>>>>>>>>>>>: k=#{k}; v=#{v};")
        pollution.concentration = (v.nil? ? nil : calc_concentration(measurement, k.to_i, v.to_f))
        pollution.save
      end
    end
  end
  
  def create_or_update
    measurement = Measurement.where("date = ? AND term = ? AND post_id = ?", params[:measurement][:date], params[:measurement][:term].to_i, params[:measurement][:post_id].to_i).first
# Rails.logger.debug("My object>>>>>>>>>>>>>>>: #{measurement.inspect}")
    if measurement.nil?
      measurement = Measurement.new(measurement_params)
      measurement.rhumb = wind_direction_to_rhumb(measurement.wind_direction)
      measurement.save
    end
    pollutions = params[:values]
    write_pollutions(measurement, pollutions)
    # redirect_to new_measurement_path
    concentrations = get_concentrations_by_measurement(measurement.id)
    render :json => { :errors => ["Данные сохранены"], concentrations: concentrations }
  end
  
  def destroy
    @measurement.destroy
    flash[:success] = "Измерение удалено"
    redirect_to measurements_path
  end
  
  def station_by_post(post_id) # converter only
    if post_id.to_i < 15
        '34519' # Донецк
      else
        '34510' # Артемовск
    end
  end
  
  def weather_update
    # synoptic_term = TERMS[params[:term].to_i]
    # так работают в Горловке
    synoptic_term = params[:term].to_i == 1 ? 21 : params[:term].to_i-4
    synoptic_date = params[:term].to_i == 1 ? (params[:date].to_date-1.day).strftime("%Y-%m-%d") : params[:date]
    weather = get_weather_from_synoptic_observatios(params[:post_id].to_i, synoptic_date, synoptic_term)
    err = weather.nil? ? "В базе не найдена погода для поста: #{params[:post_id]}, дата: #{params[:date]}, срок: #{params[:term]}" : ''
    concentrations = {}
    if weather.present?
      measurement_id = Measurement.get_id_by_date_term_post(params[:date], params[:term], params[:post_id])
      if measurement_id.present?
        concentrations = get_concentrations_by_measurement(measurement_id)
      end
    end
    render json: {weather: weather, errors: [err], concentrations: concentrations}
  end

  def get_weather_and_concentrations
    measurement = Measurement.find_by(date: params[:date], term: params[:term].to_i, post_id: params[:post_id].to_i)
    err = ''
    if measurement.present?
      concentrations = get_concentrations_by_measurement(measurement.id)
      weather = measurement.get_weather
    else
      concentrations = {}
      synoptic_term = params[:term].to_i == 1 ? 21 : params[:term].to_i-4
      synoptic_date = params[:term].to_i == 1 ? (params[:date].to_date-1.day).strftime("%Y-%m-%d") : params[:date]
      weather = get_weather_from_synoptic_observatios(params[:post_id].to_i, synoptic_date, synoptic_term)
      post = Post.find(params[:post_id])
      err = "В базе не найдена погода для поста: #{post.name}, дата: #{params[:date]}, срок: #{params[:term]}" if weather.nil?
    end
    render json: {weather: weather, errors: [err], concentrations: concentrations}
  end
  
  private
    def require_chemist
      if current_user and (current_user.role == 'chemist')
      else
        flash[:danger] = 'Вход только для химиков'
        redirect_to login_path
        return false
      end
    end

    def get_matrix_data(year, month, post_id)
      matrix = {}
      post = Post.find(post_id)
      matrix[:site_description] = post.name+'. Координаты: '+post.coordinates.to_s
      year_month = year+'-'+month+'%'      
      # select me.date, me.term, p_v.material_id, p_v.value from  pollution_values p_v join measurements me on me.id=p_v.measurement_id and me.post_id=5 and date like '2016-01%' order by me.date, me.term
      pollutions_raw = Measurement.find_by_sql("SELECT concat(DATE_FORMAT(me.date, '%Y-%m-%d '), me.term) date_term, me.*, p_v.* FROM measurements me JOIN pollution_values p_v ON p_v.measurement_id=me.id WHERE date like '#{year_month}' AND post_id = #{post_id} ORDER BY date, term")
      # measurements = Measurement.where("date like ? and post_id = ?", year_month, post_id).order(:date, :term)
      grouped_pollutions = pollutions_raw.group_by { |p| p.material_id }
      substance_codes = PollutionValue.find_by_sql("select distinct(p_v.material_id) material_id, ma.name name from  pollution_values p_v join measurements me on me.id=p_v.measurement_id and me.post_id=#{post_id} and date like '#{year_month}' JOIN materials ma ON ma.id=p_v.material_id order by p_v.material_id")
      matrix[:substance_num] = substance_codes.size
      substance_names = {}
      measure_num = Hash.new(0)
      max_values = Hash.new(0)
      avg_values = Hash.new(0)
      substance_codes.each do |s|
        k = s.material_id
        substance_names[k] = s.name
        measure_num[k] = grouped_pollutions[k].size
        grouped_pollutions[k].each {|g_p|
          value = (g_p.concentration.nil? ? g_p.value : g_p.concentration).round(4)
          max_values[k] = value if value > max_values[k]
          avg_values[k] += value
        }
        avg_values[k] = (avg_values[k]/measure_num[k]).round(3) if measure_num[k] > 0
      end
      matrix[:substance_names] = substance_names
      matrix[:measure_num] = measure_num
      matrix[:max_values] = max_values
      matrix[:avg_values] = avg_values
      grouped_pollutions = pollutions_raw.group_by { |p| p.date_term }
      pollutions = {}
      grouped_pollutions.each do |k, g_p|
        a = {}
        substance_codes.each do |s|
          a[s.material_id] = ''
        end
        g_p.each do |p| 
          a[p.material_id] = (p.concentration.nil? ? p.value : p.concentration).round(4)
        end
        pollutions[k] = a.to_a
      end
      matrix[:pollutions] = pollutions
      return matrix
    end

    def measurement_save(measurement, values)
      ret = true
      if measurement.save
        if values.present? 
          values.each do |k, v|
            material_id = k.to_i
            optical_density = v.to_f
            concentration = (optical_density.nil? ? nil : calc_concentration(measurement, material_id, optical_density))
            measurement.pollution_values.build(material_id: material_id, value: optical_density, concentration: concentration).save
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
    
    # def init_weather_params
    #   @station ||= '34519' # Донецк
    #   @date ||= Time.now.to_s(:custom_datetime)
    #   @term ||= '06'
    # end
    
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

    def get_weather_from_synoptic_observatios(post_id, date, term)
      station_id = post_id < 15 ? 1 : 7
      weather = {}
      observation = SynopticObservation.find_by(date: date, term: term, station_id: station_id)
      return nil if observation.nil?
      weather[:wind_speed] = observation.wind_speed_avg
      weather[:wind_direction] = observation.wind_direction
      weather[:temperature] = observation.temperature
      weather[:atmosphere_pressure] = observation.pressure_at_station_level
      weather
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
          pollutions = PollutionValue.find_by_sql("SELECT * FROM pollution_values p_v INNER JOIN measurements m ON m.id = p_v.measurement_id AND m.date >= '#{date_from}' AND m.date <= '#{date_to}' AND m.post_id = #{place_id} INNER JOIN posts p on p.id=m.post_id INNER JOIN materials ma ON ma.id = p_v.material_id order by p_v.material_id")
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
        concentrations[p.material_id][:values] << (p.concentration.present? ? p.concentration : p.value)
        value = (p.concentration.present? ? p.concentration : p.value)
        by_materials[p.material_id][:lt_1pdk] += 1 if value > by_materials[p.material_id][:pdk_max]
        by_materials[p.material_id][:lt_5pdk] += 1 if value > by_materials[p.material_id][:pdk_max]*5
        by_materials[p.material_id][:lt_10pdk] += 1 if value > by_materials[p.material_id][:pdk_max]*10
        if by_materials[p.material_id][:max_concentration][:value] < (p.concentration.present? ? p.concentration : p.value)
          by_materials[p.material_id][:max_concentration][:value] = (p.concentration.present? ? p.concentration.round(4) : p.value.round(4))
          by_materials[p.material_id][:max_concentration][:post_id] = p.short_name #p.post_id
          by_materials[p.material_id][:max_concentration][:date] = p.date
          by_materials[p.material_id][:max_concentration][:term] = p.term
        end
      end
      # Rails.logger.debug("concentrations =>: #{concentrations.inspect}; ")
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
      pollutions = PollutionValue.find_by_sql("SELECT p_v.id id, p_v.material_id material_id, p_v.value value, p_v.concentration concentration, ma.name name FROM pollution_values p_v INNER JOIN materials ma ON ma.id = p_v.material_id WHERE p_v.measurement_id = #{measurement_id} ORDER BY p_v.material_id")
      concentrations = {}
      pollutions.each {|p|
        concentrations[p.material_id] = {id: p.id, material_name: p.name, value: p.value, concentration: (p.concentration.nil? ? nil : p.concentration.round(4)) }
      }
      return concentrations
    end
    
    def get_place_name(region_type, place_id)
      if region_type == 'post'
        ret = Post.find(place_id).name
      else
        ret = City.find(place_id).name
      end
      return ret
    end
    
    def calc_concentration(measurement, material_id, optical_density)
      post = Post.find(measurement.post_id)
      laboratory_id = post.laboratory_id
      chem_coefficient = ChemCoefficient.find_by(material_id: material_id, laboratory_id: laboratory_id)
      if chem_coefficient.nil? 
        return optical_density # nil
      end
      t_kelvin = measurement.temperature + 273.0
      pressure = measurement.atmosphere_pressure / 1.334 # гигапаскали -> мм. рт. ст
      if material_id == 1 # пыль
        # return optical_density/v_normal*1000 # м куб -> дм куб
        v_normal = pressure/t_kelvin*0.359*post.sample_volume_dust
        return optical_density/v_normal*1000 # м куб -> дм куб
      end
      v_normal = pressure/t_kelvin*0.359*chem_coefficient.sample_volume
      m = optical_density*chem_coefficient.calibration_factor
      con = (m*chem_coefficient.solution_volume)/(v_normal*chem_coefficient.aliquot_volume)
      return con
    end

end
