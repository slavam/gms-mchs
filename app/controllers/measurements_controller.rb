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
  
  def calc_normal_volume
    @posts = Post.actual
    @date_from = params[:date_from] || Time.now.strftime("%Y-%m-01")  
    @date_to = params[:date_to] || Time.now.strftime("%Y-%m-%d")
    post_id = params[:post_id] || 5
    @post = Post.find(post_id)
    @volume_sample_dust = @post.sample_volume_dust # Объем отобраной пробы пыли в дм3
    material_id = params[:material_id] || 1
    sql = "select me.* from measurements me JOIN pollution_values p_v ON p_v.measurement_id=me.id and p_v.material_id = #{material_id} where term in (7, 19) and post_id = #{post_id} and date >= '#{@date_from}' AND date <= '#{@date_to}';"
    measurements = Measurement.find_by_sql(sql)
    @volume_total = 0
    @number_measurements = measurements.size
    measurements.each do |m|
      @volume_total += m.atmosphere_pressure/1.334/(m.temperature + 273.0)*0.359*@post.sample_volume_dust
    end
    respond_to do |format|
      format.html
      
      format.json do 
        render json: {dateFrom: @date_from, dateTo: @date_to, volumeTotal: @volume_total.round(4), volumeSampleDust: @volume_sample_dust, post: @post, numberMeasurements: @number_measurements}
      end
    end
  end

  def chem_forma1_tza
    @year = Time.now.year.to_s
    @month = Time.now.month.to_s.rjust(2, '0')
    @post_id =  5 # 20 for Gorlovka
    @matrix = get_matrix_forma1(@year, @month, @post_id)
    @posts = Post.actual.order(:id) 
  end
  
  def chem_forma1_as_protocol
    respond_to do |format|
      format.pdf do
        year = params[:year]
        month = params[:month]
        post_id = params[:post_id]
        matrix = get_matrix_forma1(year, month, post_id)
        header0 = ["<b>Дата</b>", "<b>Срок</b>"]
        matrix[:substance_names].each {|h| header0 << "<b>#{h[1]}</b> мг/м<sup>3</sup>"}
        pollutions = []
        pollutions << header0
        matrix[:pollutions].each do |k, p|
          pollutions << make_forma1_row(k, p, 'protocol')
        end
        pollutions << ["<b>Число измерений</b>", ""] + matrix[:measure_num].map{|k,v| v}
        pollutions << ["<b>Среднее</b>", ""] + matrix[:avg_values].map{|k,v| v.round(5)}
        pollutions << ["<b>Максимум</b>", ""] + matrix[:max_values].map{|k,v| v.round(5)}
        # Rails.logger.debug("My object>>>>>>>>>>>>>>>: #{matrix[:pollutions].inspect}")
        pdf = ChemForma1AsProtocol.new(year, month, post_id, pollutions, matrix[:site_description])
        send_data pdf.render, filename: "chem_forma1_as_protocol_#{current_user.id}.pdf", type: "application/pdf", disposition: "inline", :force_download=>true, :page_size => "A4"
      end
    end
  end

  # def wind_rose_2
  #   @year = params[:year].present? ? params[:year] : Time.now.year.to_s
  #   @city_id = params[:city_id].present? ? params[:city_id].to_i : 1
  #   @cities = City.all.order(:id)
  #   @city_name = City.find(@city_id).name
  #   sql ="select date, wind_speed, wind_direction from measurements m join posts p on p.id = m.post_id and p.city_id = #{@city_id} where date like '#{@year}%' order by date;"
  #   observations = Measurement.find_by_sql(sql)
  #   total = observations.size
  #   total_wind = 0
  #   total_1 = 0
  #   total_7 = 0
  #   total_wind_1 = 0
  #   total_wind_7 = 0
  #   direct_by_month = Hash.new 0
  #   observations.each do |o| 
  #     month = o.date.month
  #     if (o.wind_direction == 0) and (o.wind_speed == 0) # calm
  #       direct_by_month[[0,8]] += 1 # calm by year
  #       if [1,7].include? month #calm by month
  #         direct_by_month[[month,8]] += 1 
  #         if month == 1
  #           total_1 += 1
  #         else
  #           total_7 += 1
  #         end
  #       end
  #     else
  #       total_wind += 1 # case with wind
  #       if [1,7].include? month # wind by month
  #         direction = get_wind_direction(o.wind_direction)
  #         direct_by_month[[month, direction]] += 1
  #         direct_by_month[[0, direction]] += 1
  #         if month == 1
  #           total_1 += 1
  #           total_wind_1 += 1
  #         else
  #           total_7 += 1
  #           total_wind_7 += 1
  #         end
  #       end
  #     end
  #   end
  #   @matrix = Hash.new(0)
  #   @max_value = 0
  #   (0..8).each do |d|
  #     if direct_by_month.key?([0,d])
  #       @matrix[[0,d]] = direct_by_month[[0,d]]*100.0/(d == 8 ? total : total_wind)  
  #     else
  #       @matrix[[0,d]] = 0
  #     end
  #     @max_value = @matrix[[0,d]] if @matrix[[0,d]] > @max_value
  #     if wind_by_month.key?([1,d])
  #       @matrix[[1,d]] = wind_by_month[[1,d]]*100.0/(d == 8 ? wind_01 : total_01) 
  #     else
  #       @matrix[[1,d]] = 0
  #     end
  #     @max_value = @matrix[[1,d]] if @matrix[[1,d]] > @max_value
  #     if wind_by_month.key?([7,d])
  #       @matrix[[7,d]] = wind_by_month[[7,d]]*100.0/(d == 8 ? wind_07 : total_07) 
  #     else
  #       @matrix[[7,d]] = 0
  #     end
  #     @max_value = @matrix[[7,d]] if @matrix[[7,d]] > @max_value
  #   end

  # end
  
  def get_wind_direction(direction)
    case direction
      when 4..7 # NE
        return 1
      when 8..12 # E
        return 2
      when 13..16 # SE
        return 3
      when 17..21 # S
        return 4
      when 22..25 # SW
        return 5
      when 26..30 # W
        return 6
      when 31..34 # NW
        return 7
      else # N
        return 0
    end
  end
  
  def wind_rose
    @year = params[:year].present? ? params[:year] : Time.now.year.to_s
    @city_id = params[:city_id].present? ? params[:city_id].to_i : 1
    @cities = City.all.order(:id)
    @city_name = City.find(@city_id).name
    sql ="select date, wind_speed, wind_direction from measurements m join posts p on p.id = m.post_id and p.city_id = #{@city_id} where date like '#{@year}%' order by date;"
    observations = Measurement.find_by_sql(sql)
    wind_by_month = Hash.new 0
    total = observations.size
    only_wind_total = 0
    total_01 = 0
    total_07 = 0
    wind_01 = 0
    wind_07 = 0
    observations.each do |o| 
      month = o.date.month
      # total += 1
      total_01 += 1 if month == 1
      total_07 += 1 if month == 7
      if (o.wind_direction == 0) and (o.wind_speed == 0)
        wind_by_month[[month, 8]] += 1 # calm
        wind_by_month[[0, 8]] += 1
      else 
        only_wind_total += 1
        wind_01 += 1 if month == 1
        wind_07 += 1 if month == 7
        case o.wind_direction
          when 4..7 # NE
            wind_by_month[[month, 1]] += 1
            wind_by_month[[0, 1]] += 1
          when 8..12 # E
            wind_by_month[[month, 2]] += 1
            wind_by_month[[0, 2]] += 1
          when 13..16 # SE
            wind_by_month[[month, 3]] += 1
            wind_by_month[[0, 3]] += 1
          when 17..21 # S
            wind_by_month[[month, 4]] += 1
            wind_by_month[[0, 4]] += 1
          when 22..25 # SW
            wind_by_month[[month, 5]] += 1
            wind_by_month[[0, 5]] += 1
          when 26..30 # W
            wind_by_month[[month, 6]] += 1
            wind_by_month[[0, 6]] += 1
          when 31..34 # NW
            wind_by_month[[month, 7]] += 1
            wind_by_month[[0, 7]] += 1
          else # N
            wind_by_month[[month, 0]] += 1
            wind_by_month[[0, 0]] += 1
        end
      end
    end
    # Rails.logger.debug("My object>>>>>>>>>>>>>>>роза_ветров: #{wind_by_month.inspect} , total-> #{total}, wind_total=>#{only_wind_total} ") 
    @matrix = Hash.new(0)
    # @max_year = 0
    # @max_jan = 0
    @max_jul = 0
    (0..8).each do |d|
      if wind_by_month.key?([0,d])
        @matrix[[0,d]] = wind_by_month[[0,d]]*100.0/(d == 8 ? total : only_wind_total)  
      else
        @matrix[[0,d]] = 0
      end
      # @max_year = @matrix[[0,d]] if @matrix[[0,d]] > @max_year
      if wind_by_month.key?([1,d])
        @matrix[[1,d]] = wind_by_month[[1,d]]*100.0/(d == 8 ? total_01 : wind_01) 
      else
        @matrix[[1,d]] = 0
      end
      # @max_jan = @matrix[[1,d]] if @matrix[[1,d]] > @max_jan
      if wind_by_month.key?([7,d])
        @matrix[[7,d]] = wind_by_month[[7,d]]*100.0/(d == 8 ? total_07 : wind_07) 
      else
        @matrix[[7,d]] = 0
      end
      @max_jul = @matrix[[7,d]] if @matrix[[7,d]] > @max_jul
    end
    # @duble = wind_by_month
    
    respond_to do |format|
      format.html
      format.pdf do
        pdf = WindRose.new(@matrix, @city_name, @year, current_user.id)
        send_data pdf.render, filename: "wind_rose_#{current_user.id}.pdf", type: "application/pdf", disposition: "inline", :force_download=>true, :page_size => "A4"
      end
      format.json do 
        render json: {matrix: @matrix, cityName: @city_name, year: @year, maxValue: @max_value}
      end
    end
  end
  
  def print_wind_rose
    # Rails.logger.debug("My object>>>>>>>>>>>>>>>роза_ветров: #{params.inspect}")
    chart = params[:canvas_image].split(',')
    image = Base64.decode64(chart[1])
    if Rails.env.production?
      filename = "#{Rails.root}/public/images/wind_rose_#{current_user.id}.png"  # production only
    else
      filename = "app/assets/pdf_folder/wind_rose_#{current_user.id}.png"
    end
    begin
      file = File.open(filename, 'wb')
      file.write(image) 
    rescue IOError => e
      Rails.logger.debug("My object>>>>>>>>>>>>>>>роза_ветров: #{e.inspect}")
      render json: {error: "Caught the exception: #{e}"}
    ensure
      file.close unless file.nil?
    end
    # begin
    #   # file = File.new(filename, 'wb')
    #   File.open(filename, 'wb') do |f|
    #     f.write(image)
    #   end
    #   # file.close
    # rescue Errno::ENOENT => e
    #   Rails.logger.debug("My object>>>>>>>>>>>>>>>роза_ветров: #{e.inspect}")
    #   render json: {error: "Caught the exception: #{e}"}
    # end
    render json: {saved_at: Time.now.to_s}
  end
  
  def observations_quantity
    @date_from = params[:date_from].present? ? params[:date_from]+' 00:00:00' : Time.now.beginning_of_month.strftime("%Y-%m-%d %H:%M:%S")
    @date_to = params[:date_to].present? ? params[:date_to]+' 23:59:59' : Time.now.end_of_month.strftime("%Y-%m-%d %H:%M:%S")
    @city_id = params[:city_id].present? ? params[:city_id] : 1
    @cities = City.all.order(:id)
    @materials = Material.actual_materials
    @posts = Post.actual.order(:id)
    
    sql = "select distinct(material_id) id,  post_id, count(*) term from pollution_values p_v join measurements m on p_v.measurement_id=m.id join posts p on p.id = m.post_id and p.city_id = #{@city_id} and date > '#{@date_from}' and date < '#{@date_to}' group by material_id, m.post_id;"
    # sql ="select distinct(material_id),  post_id, count(*) num from pollution_values p_v join measurements m on p_v.measurement_id=m.id and date > '#{date_from}' and date < '#{date_to}' group by material_id, post_id;"
    observations = Measurement.find_by_sql(sql)
    @quantity = Hash.new(0)
    @total = 0
    observations.each do |o| 
      @quantity[[o.id, o.post_id]] = o.term
      @total += o.term
    end
    respond_to do |format|
      format.html
      format.pdf do
        city = City.find(@city_id)
        city_name = city.name+' ('+city.code.to_s+')'
        pdf = ChemObservationsQuantity.new(@quantity, @date_from[0,10], @date_to[0,10], @total, city_name, @city_id, @materials, @posts)
        send_data pdf.render, filename: "chem_observations_quantity_#{current_user.id}.pdf", type: "application/pdf", disposition: "inline", :force_download=>true, :page_size => "A4", :page_layout => "landscape"
      end
      format.json do 
        render json: {observations: @quantity, total: @total}
      end
    end
  end

  def get_chem_forma1_tza_data
    month = params[:month]
    year = params[:year]
    post_id = params[:post_id]
    matrix = get_matrix_forma1(year, month, post_id)
    render json: {year: year, month: month, matrix: matrix, postId: post_id}
  end

  def make_forma1_row(k, ps, mode)
    ndigits_protocol = []
    ndigits_protocol[1] = 3  # Пыль – 0,00Х
    ndigits_protocol[2] = 4  # Диоксид серы – 0,000Х
    ndigits_protocol[4] = 1  # Оксид углерода – 0,Х
    ndigits_protocol[5] = 4  # Диоксид азота – 0,000Х
    ndigits_protocol[6] = 4  # Оксид азота – 0,000Х
    ndigits_protocol[8] = 5  # Сероводород - 0,0000Х
    ndigits_protocol[10] = 5  # Фенол – 0,0000Х
    ndigits_protocol[19] = 4  # Аммиак – 0,000Х
    ndigits_protocol[22] = 4  # Формальдегид – 0,000Х

    row = []
    row[0] = k[0,10]
    row[1] = k[11,2]
    ps.each do|v| 
      if v[1].kind_of? String
        row << ''
      else
        row << v[1].to_f.round(mode.present? ? (ndigits_protocol[v[0]].present? ? ndigits_protocol[v[0]] : 5) : get_digits(v[0].to_i))
      end
    end
    return row
  end
  
  def print_forma1_tza
    @year = params[:year]
    @month = params[:month]
    @post_id = params[:post_id]
    @matrix = get_matrix_forma1(@year, @month, @post_id)
    header0 = ["<b>Дата</b>", "<b>Срок</b>"]
    @matrix[:substance_names].each {|h| header0 << "<b>#{h[1]}</b> мг/м<sup>3</sup>"}
    @pollutions = []
    @pollutions << header0
    @matrix[:pollutions].each do |k, p|
      @pollutions << make_forma1_row(k, p, nil)
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
    @date_from = Time.now.strftime("%Y-%m-01") # '2016-02-01' # 
    @date_to = Time.now.strftime("%Y-%m-%d")
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

    def get_matrix_forma1(year, month, post_id)
      # 2018-02-20 from Gorlovka
      # 1 Пыль – 0,087 
      # 2 Диоксид серы – 0
      # 4 Углерода оксид 0
      # 5 Диоксид азота – 0,0067
      # 8 Сероводород - 0,0010
      # 10 Фенол – 0,0010
      # 19 Аммиак – 0,0033
      # 22 Формальдегид – 0,0033
      limits = {1 => 0.087, 2 => 0, 3 => 1, 4 => 0, 5 => 0.0067, 6 => 0, 8 => 0.001, 10 => 0.001, 19 => 0.0033, 22 => 0.0033}
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
        max_values[k] = 0.0
        substance_names[k] = s.name
        measure_num[k] = grouped_pollutions[k].size
        grouped_pollutions[k].each {|g_p|
          value = (g_p.concentration.nil? ? g_p.value : g_p.concentration)
          if value < limits[k]
            value = 0
          end
          max_values[k] = value.round(5) if value > max_values[k]
          avg_values[k] += value
        }
        avg_values[k] = (avg_values[k]/measure_num[k]).round(5) if measure_num[k] > 0
      end
      # Rails.logger.debug("My object: #{max_values.inspect}")
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
          a[p.material_id] = (p.concentration.nil? ? p.value : p.concentration) #.round(get_digits(p.material_id))
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
    
    def get_digits(n)
      ndigits = []
      ndigits[1] = 2
      ndigits[2] = 3
      ndigits[4] = 0
      ndigits[5] = 2
      ndigits[6] = 2
      ndigits[8] = 3
      ndigits[10] = 3
      ndigits[19] = 2
      ndigits[22] = 3
      return ndigits[n] || 4
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
        concentrations[p.material_id][:values] << (p.concentration.present? ? p.concentration : p.value).round(get_digits(p.material_id))
        value = (p.concentration.present? ? p.concentration : p.value).round(get_digits(p.material_id))
        by_materials[p.material_id][:lt_1pdk] += 1 if value > by_materials[p.material_id][:pdk_max]
        by_materials[p.material_id][:lt_5pdk] += 1 if value > by_materials[p.material_id][:pdk_max]*5
        by_materials[p.material_id][:lt_10pdk] += 1 if value > by_materials[p.material_id][:pdk_max]*10
        if by_materials[p.material_id][:max_concentration][:value] < (p.concentration.present? ? p.concentration : p.value).round(get_digits(p.material_id))
          by_materials[p.material_id][:max_concentration][:value] = (p.concentration.present? ? p.concentration : p.value).round(get_digits(p.material_id))
          by_materials[p.material_id][:max_concentration][:post_id] = p.short_name #p.post_id
          by_materials[p.material_id][:max_concentration][:date] = p.date
          by_materials[p.material_id][:max_concentration][:term] = p.term
        end
      end
      # Rails.logger.debug("concentrations =>: #{concentrations.inspect}; ")
      material_ids.each do |m|
        by_materials[m][:size] = concentrations[m][:values].size
        by_materials[m][:mean] = concentrations[m][:values].mean.round(get_digits(m))
        by_materials[m][:standard_deviation] = concentrations[m][:values].standard_deviation.round(4)
        by_materials[m][:variance] = (by_materials[m][:standard_deviation]/by_materials[m][:mean]).round(4) if by_materials[m][:mean] > 0
        by_materials[m][:percent1] = (by_materials[m][:lt_1pdk]/by_materials[m][:size].to_f*100.0).round(2)
        by_materials[m][:percent5] = (by_materials[m][:lt_5pdk]/by_materials[m][:size].to_f*100.0).round(2)
        by_materials[m][:percent10] = (by_materials[m][:lt_10pdk]/by_materials[m][:size].to_f*100.0).round(2)
        by_materials[m][:pollution_index] = ((by_materials[m][:mean]/by_materials[m][:pdk_avg])**HAZARD_CLASS[by_materials[m][:hazard_index]]).round(4)
        by_materials[m][:avg_conc] = (by_materials[m][:mean]/by_materials[m][:pdk_avg]).round(3)
        by_materials[m][:max_conc] = (by_materials[m][:max_concentration][:value]/by_materials[m][:pdk_max]).round(3)
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
    
    # def calc_concentration(measurement, material_id, optical_density)
    #   post = Post.find(measurement.post_id)
    #   laboratory_id = post.laboratory_id
    #   chem_coefficient = ChemCoefficient.find_by(material_id: material_id, laboratory_id: laboratory_id)
    #   if chem_coefficient.nil? 
    #     return optical_density # nil
    #   end
    #   t_kelvin = measurement.temperature + 273.0
    #   pressure = measurement.atmosphere_pressure / 1.334 # гигапаскали -> мм. рт. ст
    #   if material_id == 1 # пыль
    #     v_normal = pressure/t_kelvin*0.359*post.sample_volume_dust
    #     return optical_density/v_normal*1000 # м куб -> дм куб
    #   end
    #   v_normal = pressure/t_kelvin*0.359*chem_coefficient.sample_volume
    #   m = optical_density*chem_coefficient.calibration_factor
    #   con = (m*chem_coefficient.solution_volume)/(v_normal*chem_coefficient.aliquot_volume)
    #   return con
    # end
    
   

end
