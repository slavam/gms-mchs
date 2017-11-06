class SynopticObservationsController < ApplicationController
  # before_filter :require_observer_or_technicist
  before_filter :find_synoptic_observation, only: [:show, :update_synoptic_telegram] 

  def get_conversion_params
  end
  
  def converter
    date_from = params[:interval][:date_from].tr("-", ".")+' 00:00:00'
    date_to = params[:interval][:date_to].tr("-", ".")+' 23:59:59'
    old_telegrams = OldSynopticTelegram.where("Дата >= ? and Дата <= ? and Срок in (?)", date_from, date_to, OldSynopticTelegram::TERMS)
    stations = Station.station_id_by_code
    # Rails.logger.debug("My object>>>>>>>>>>>>>>>: #{stations.inspect}")
    selected_telegrams = old_telegrams.size
    wrong_telegrams = 0
    correct_telegrams = 0
    File.open("app/assets/pdf_folder/conversion.txt",'w') do |mylog|
      mylog.puts "Конверсия данных за период с #{date_from} по #{date_to}"
      old_telegrams.each do |t|
        errors = []
        telegram = convert_synoptic_telegram(t, stations, errors)
        if telegram.present?
          correct_telegrams += 1
        else
          mylog.puts errors[0]+' => '+t["Телеграмма"]
          wrong_telegrams += 1
        end
      end
      mylog.puts '='*80
      mylog.puts "Всего поступило телеграмм - #{selected_telegrams}"
      mylog.puts "Корректных телеграмм - #{correct_telegrams}"
      mylog.puts "Ошибочных телеграмм - #{wrong_telegrams}"
    end
    flash[:success] = "Входных телеграмм - #{selected_telegrams}. Сохранено телеграмм - #{correct_telegrams}. Ошибочных телеграмм - #{wrong_telegrams}."
    redirect_to synoptic_observations_get_conversion_params_path
  end
  
  def search_synoptic_telegrams
    @date_from ||= params[:date_from].present? ? params[:date_from] : Time.now.strftime("%Y-%m-%d")
    @date_to ||= params[:date_to].present? ? params[:date_to] : Time.now.strftime("%Y-%m-%d")
    term = params[:term].present? ? " and term = #{params[:term]}" : ''
    station_id = params[:station_code].present? ? Station.find_by_code(params[:station_code]).id : nil
    station = station_id.present? ? " and station_id = #{station_id}" : ''
    text = params[:text].present? ? " and telegram like '%#{params[:text]}%'" : ''
       
    sql = "select * from synoptic_observations where date >= '#{@date_from}' and date <= '#{@date_to} 23:59:59' #{term} #{station} #{text};"
    tlgs = SynopticObservation.find_by_sql(sql)
    @stations = Station.all.order(:name)
    @stations << {code: 0, name: 'Любая'}
    @telegrams = fields_short_list(tlgs)
    respond_to do |format|
      format.html 
      format.json { render json: {telegrams: @telegrams} }
    end
  end

  def index
    @synoptic_observations = SynopticObservation.paginate(page: params[:page]).order(:date, :term).reverse_order
  end
  
  def synoptic_storm_telegrams
    sql = "SELECT created_at, date as date_rep, term as fterm, station_id, telegram from synoptic_observations union select created_at, telegram_date as date_rep, 'Ш' as fterm, station_id, telegram from storm_observations order by date_rep desc, created_at desc limit 100;"
    @telegrams = SynopticObservation.find_by_sql(sql)
  end
    
  def show
  end
  
  def new
    # @date = Time.now.to_s(:simple_date_time)
    # Rails.logger.debug("My object>>>>>>>>>>>>>>>: #{current_user.inspect}")
    @stations = Station.all.order(:name)
    @last_telegrams = SynopticObservation.short_last_50_telegrams
    # @last_telegrams = fields_short_list(last_telegrams)
  end
  
  def create_synoptic_telegram
    telegram = SynopticObservation.new(observation_params)
    telegram.station_id = Station.find_by_code(telegram.telegram[6,5].to_i).id
    if telegram.save
      last_telegrams = SynopticObservation.short_last_50_telegrams
      render json: {telegrams: last_telegrams, tlgType: 'synoptic', currDate: telegram.date, errors: ["Телеграмма добавлена в базу"]}
    else
      render json: {errors: telegram.errors.messages}, status: :unprocessable_entity
    end
  end
  
  def update_synoptic_telegram
    if @synoptic_observation.update_attributes observation_params
      render json: {errors: []}
    else
      render json: {errors: ["Ошибка при сохранении изменений"]}, status: :unprocessable_entity
    end
    # Rails.logger.debug("My object>>>>>>>>>>>>>>>: #{@synoptic_observation.inspect}")
    # Rails.logger.debug("My object+++++++++++++++: #{params[:observation].inspect}")
  end
  
  def heat_donbass_show
    @calc_date = params[:calc_date].present? ? params[:calc_date] : Time.now.strftime("%Y-%m-%d")
    @temperatures = get_temperatures(@calc_date) # ("2017-10-08") 
    # Rails.logger.debug("My object>>>>>>>>>>>>>>>: #{@temperatures.inspect}")
  end
  
  def get_temps
    calc_date = params[:calc_date].present? ? params[:calc_date] : Time.now.strftime("%Y-%m-%d")
    temperatures = get_temperatures(calc_date)
    render json: {temperatures: temperatures, calcDate: calc_date}
  end
  
  def input_synoptic_telegrams
    @stations = Station.all.order(:name)
    @telegrams = SynopticObservation.short_last_50_telegrams
  end
  
  def get_last_telegrams
    telegrams = SynopticObservation.short_last_50_telegrams
    render json: {telegrams: telegrams, tlgType: 'synoptic'}
  end

  private
    def get_temperatures(date)
      heat_data = SynopticObservation.select(:id, :station_id, :term, :temperature).where("date like ? and station_id in (1, 2, 3, 4, 5)", date).order(:station_id, :term)
      a = Hash.new(nil)
      heat_data.each {|hd|
        a[[hd.station_id, hd.term]] = hd.temperature
      }
      a
    end
    
    def find_synoptic_observation
      @synoptic_observation = SynopticObservation.find(params[:id])
    end
    
    def observation_params
      params.require(:observation).permit(:date, :term, :telegram, :station_id, :cloud_base_height,
        :visibility_range, :cloud_amount_1, :wind_direction, :wind_speed_avg, :temperature, :temperature_dew_point, 
        :pressure_at_station_level, :pressure_at_sea_level, :pressure_tendency_characteristic, :pressure_tendency,
        :precipitation_1, :precipitation_time_range_1, :weather_in_term, :weather_past_1, :weather_past_2,
        :cloud_amount_2, :clouds_1, :clouds_2, :clouds_3, :temperature_dey_max, :temperature_night_min, 
        :underlying_surface_сondition, :snow_cover_height, :sunshine_duration, :cloud_amount_3, :cloud_form,
        :cloud_height, :weather_data_add, :soil_surface_condition_1, :temperature_soil, :soil_surface_condition_2,
        :temperature_soil_min, :temperature_2cm_min, :precipitation_2, :precipitation_time_range_2)
    end
    
    def convert_synoptic_telegram(old_telegram, stations, errors)
      groups = old_telegram["Телеграмма"].split(' ')
      new_telegram = SynopticObservation.new
      new_telegram.date = old_telegram["Дата"].tr('.', '-')
      new_telegram.term = old_telegram["Срок"].to_i
      new_telegram.telegram = old_telegram["Телеграмма"]
      if ((groups[0] == "ЩЭСМЮ" ) && (new_telegram.term % 2 == 0)) || ((groups[0] == "ЩЭСИД") && (new_telegram.term % 2 == 1))
      else 
        errors.push("Ошибка в различительной группе");
        return nil;
      end
      code_station = groups[1].to_i
      if stations[code_station].present?
        new_telegram.station_id = stations[code_station]
      else
        errors << "Ошибка в коде станции - <#{code_station}>"
        return nil
      end
      new_telegram.cloud_base_height = groups[2][2].to_i if groups[2][2] != '/'
      new_telegram.visibility_range = groups[2][3,2].to_i if groups[2][3] != '/'
      new_telegram
    end
    
    def require_observer_or_technicist
      if current_user and ((current_user.role == 'observer') || (current_user.role == 'technicist'))
        return true
      else
        flash[:danger] = 'Вход только для наблюдателей'
        redirect_to login_path
        return false
      end
    end
    
    def fields_short_list(full_list)
      # stations = Station.all
      full_list.map do |rec|
        {id: rec.id, date: rec.date, term: rec.term, station_name: rec.station.name, telegram: rec.telegram}
      end
    end
end
