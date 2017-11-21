class SynopticObservationsController < ApplicationController
  # before_filter :require_observer_or_technicist
  before_filter :find_synoptic_observation, only: [:show, :update_synoptic_telegram] 

  def get_conversion_params
  end
  
  def converter
    date_from = params[:interval][:date_from].tr("-", ".")+' 00:00:00'
    date_to = params[:interval][:date_to].tr("-", ".")+' 23:59:59'
    old_telegrams = OldSynopticTelegram.where("Дата >= ? and Дата <= ? and Срок in (?) ", date_from, date_to, OldSynopticTelegram::TERMS).order("Дата, Срок")
    stations = Station.station_id_by_code
    selected_telegrams = old_telegrams.size
    wrong_telegrams = 0
    correct_telegrams = 0
    created_telegrams = 0
    updated_telegrams = 0
    skiped_telegrams = 0
    File.open("app/assets/pdf_folder/conversion.txt",'w') do |mylog|
      mylog.puts "Конверсия данных синоптических телеграмм за период с #{date_from} по #{date_to}"
      old_telegrams.each do |t|
        errors = []
        telegram = convert_synoptic_telegram(t, stations, errors)
        if telegram.present?
          observation = SynopticObservation.find_by(date: telegram.date, term: telegram.term, station_id: telegram.station_id)
          if observation.present?
            # Rails.logger.debug("My object>>>>>>>>>>>>>>>updated_telegrams: #{hash_telegram.inspect}") 
            if observation.observed_at.nil? or (observation.observed_at < telegram.observed_at) 
              json_telegram = telegram.as_json.except('id', 'created_at', 'updated_at')
              observation.update_attributes json_telegram 
              updated_telegrams += 1
            else
              skiped_telegrams += 1
            end
          else
            observation = SynopticObservation.new(telegram.as_json)
            observation.save
            created_telegrams += 1
          end
          correct_telegrams += 1
        else
          mylog.puts errors[0]+' => '+t["Дата"]+'->'+t["Срок"]+'->'+t["Телеграмма"]
          wrong_telegrams += 1
        end
      end
      mylog.puts '='*80
      mylog.puts "Всего поступило телеграмм - #{selected_telegrams}"
      mylog.puts "Корректных телеграмм - #{correct_telegrams}: создано - #{created_telegrams}; обновлено - #{updated_telegrams}; пропущено - #{skiped_telegrams}"
      mylog.puts "Ошибочных телеграмм - #{wrong_telegrams}"
    end
    flash[:success] = "Входных телеграмм - #{selected_telegrams}. Корректных телеграмм - #{correct_telegrams} (создано - #{created_telegrams}; обновлено - #{updated_telegrams}; пропущено - #{skiped_telegrams}). Ошибочных телеграмм - #{wrong_telegrams}."
    redirect_to synoptic_observations_get_conversion_params_path
  end
  
  def search_synoptic_telegrams
    @date_from ||= params[:date_from].present? ? params[:date_from] : Time.now.strftime("%Y-%m-%d")
    @date_to ||= params[:date_to].present? ? params[:date_to] : Time.now.strftime("%Y-%m-%d")
    term = params[:term].present? ? " and term = #{params[:term]}" : ''
    station_id = params[:station_code].present? ? Station.find_by_code(params[:station_code]).id : nil
    station = station_id.present? ? " and station_id = #{station_id}" : ''
    text = params[:text].present? ? " and telegram like '%#{params[:text]}%'" : ''
       
    sql = "select * from synoptic_observations where observed_at >= '#{@date_from}' and observed_at <= '#{@date_to} 23:59:59' #{term} #{station} #{text} order by observed_at desc;"
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
    @synoptic_observations = SynopticObservation.paginate(page: params[:page]).order(:observed_at, :term).reverse_order
  end
  
  def synoptic_storm_telegrams
    sql = "SELECT created_at, observed_at as date_rep, term as fterm, station_id, telegram from synoptic_observations union select created_at, telegram_date as date_rep, 'Ш' as fterm, station_id, telegram from storm_observations order by date_rep desc, created_at desc limit 100;"
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
    telegram.observed_at = Time.now
    telegram.term = Time.now.hour / 3 * 3
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
        :temperature_soil_min, :temperature_2cm_min, :precipitation_2, :precipitation_time_range_2, :observed_at)
    end
    
    def convert_synoptic_telegram(old_telegram, stations, errors)
      groups = old_telegram["Телеграмма"].tr('=', '').split(' ')
      new_telegram = SynopticObservation.new
      new_telegram.date = old_telegram["Дата"].tr('.', '-')
      new_telegram.observed_at = Time.parse(old_telegram["Дата"])
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
      
      if (groups[2] =~ /^[134\/][1-4][0-9\/]([0-4][0-9]|50|5[6-9]|[6-9][0-9]|\/\/)$/).nil?
        errors << "Ошибка в группе 00"
        return nil
      end
      new_telegram.cloud_base_height = groups[2][2].to_i if groups[2][2] != '/'
      new_telegram.visibility_range = groups[2][3,2].to_i if groups[2][3] != '/'
      if (groups[3] =~ /^[0-9\/]([012][0-9]|3[0-6]|99|\/\/)([012][0-9]|30|\/\/)$/).nil?
        errors << "Ошибка в группе 0"
        return nil
      end
      new_telegram.cloud_amount_1 = groups[3][0].to_i if groups[3][0] != '/'
      new_telegram.wind_direction = groups[3][1,2].to_i if groups[3][1] != '/'
      new_telegram.wind_speed_avg = groups[3][3,2].to_i if groups[3][3] != '/'
      if (groups[4] =~ /^1[01][0-5][0-9][0-9]$/).nil?
        errors << "Ошибка в группе 1 раздела 1"
        return nil
      end
      sign = groups[4][1] == '0' ? '' : '-'
      val = sign+groups[4][2,2]+'.'+groups[4][4]
      new_telegram.temperature = val.to_f
      if (groups[5] =~ /^2[01][0-5][0-9][0-9]$/).nil?
        errors << "Ошибка в группе 2 раздела 1"
        return nil
      end
      sign = groups[5][1] == '0' ? '' : '-'
      val = sign+groups[5][2,2]+'.'+groups[5][4]
      new_telegram.temperature_dew_point = val.to_f
      pos333 = new_telegram.telegram =~ / 333 /
      pos555 = new_telegram.telegram =~ / 555 /
      len = pos333.present? ? pos333 : (pos555.present? ? pos555 : new_telegram.telegram.size-1)
      section = new_telegram.telegram[26,len-26]
      g_pos = section =~ / 3.... /
      if g_pos.present?
        group = section[g_pos+1,5]
        if (group =~ /^3\d{4}$/).present?
          first = group[1] == '0' ? '1' : '';
          val = first+group[1,3]+'.'+group[4];
          new_telegram.pressure_at_station_level = val.to_f
        else
          errors << "Ошибка в группе 3 раздела 1"
          return nil
        end
      end
      g_pos = section =~ / 4.... /
      if g_pos.present?
        group = section[g_pos+1,5]
        if (group =~ /^4\d{4}$/).present?
          first = group[1] == '0' ? '1' : ''
          val = first+group[1,3]+'.'+group[4]
          new_telegram.pressure_at_sea_level = val.to_f
        else
          errors << "Ошибка в группе 4 раздела 1"
          return nil
        end
      end
      g_pos = section =~ / 5.... /
      if g_pos.present?
        group = section[g_pos+1,5]
        if (group =~ /^5[0-8]\d{3}$/).present?
          new_telegram.pressure_tendency_characteristic = group[1].to_i
          new_telegram.pressure_tendency = (group[2,2]+'.'+group[4]).to_f
        else
          errors << "Ошибка в группе 5 раздела 1"
          return nil
        end
      end
      g_pos = section =~ / 6..../
      if g_pos.present?
        group = section[g_pos+1,5]
        if (group =~ /^6\d{3}[12]$/).present?
          new_telegram.precipitation_1 = group[1,3].to_i
          new_telegram.precipitation_time_range_1 = group[4].to_i
        else
          errors << "Ошибка в группе 6 раздела 1"
          return nil
        end
      end
      g_pos = section =~ / 7..../
      if g_pos.present?
        group = section[g_pos+1,5]
        if (group =~ /^7\d{4}$/).present?
          new_telegram.weather_in_term = group[1,2].to_i
          new_telegram.weather_past_1 = group[3].to_i
          new_telegram.weather_past_2 = group[4].to_i
        else
          errors << "Ошибка в группе 7 раздела 1"
          return nil
        end
      end
      g_pos = section =~ / 8..../
      if g_pos.present?
        group = section[g_pos+1,5]
        if (group =~ /^8[0-9\/]{4}$/).present?
          if group[1] != '/'
            new_telegram.cloud_amount_2 = group[1].to_i
            new_telegram.clouds_1 = group[2].to_i
            new_telegram.clouds_2 = group[3].to_i
            new_telegram.clouds_3 = group[4].to_i
          end
        else
          errors << "Ошибка в группе 8 раздела 1"
          return nil
        end
      end
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
      if pos333.present?
        # pos555 = new_telegram.telegram =~ / 555 /
        len = pos555.present? ? pos555 : new_telegram.telegram.size-1
        section = new_telegram.telegram[pos333+4,len-pos333-4]
        g_pos = section =~ / 1..../
        if g_pos.present?
          group = section[g_pos+1,5]
          if (group =~ /^1[01][0-9]{3}$/).present?
            sign = group[1] == '0' ? '' : '-'
            val = sign+group[2,2]+'.'+group[4]
            new_telegram.temperature_dey_max = val.to_f
          else
            errors << "Ошибка в группе 1 раздела 3"
            return nil
          end
        end
        g_pos = section =~ / 2..../
        if g_pos.present?
          group = section[g_pos+1,5]
          if (group =~ /^2[01][0-9]{3}$/).present?
            sign = group[1] == '0' ? '' : '-'
            val = sign+group[2,2]+'.'+group[4]
            new_telegram.temperature_night_min = val.to_f
          else
            errors << "Ошибка в группе 2 раздела 3"
            return nil
          end
        end
        g_pos = section =~ / 4..../
        if g_pos.present?
          group = section[g_pos+1,5]
          if (group =~ /^4[0-9\/][0-9]{3}$/).present?
            if group[1] != '/'
              new_telegram.underlying_surface_сondition = group[1].to_i
              new_telegram.snow_cover_height = group[2,3].to_i
            end
          else
            errors << "Ошибка в группе 4 раздела 3"
            return nil
          end
        end
        g_pos = section =~ / 55.../
        if g_pos.present?
          group = section[g_pos+1,5]
          if (group =~ /^55[0-9]{3}$/).present?
            new_telegram.sunshine_duration = (group[2,2]+'.'+group[4]).to_f
          else
            errors << "Ошибка в группе 5 раздела 3"
            return nil
          end
        end
        g_pos = section =~ / 8..../
        if g_pos.present?
          group = section[g_pos+1,5]
          if (group =~ /^8[0-9\/]{2}([0-4][0-9]|50|5[6-9]|[6-9][0-9])$/).present?
            if group[1] != '/'
              new_telegram.cloud_amount_3 = group[1].to_i
              new_telegram.cloud_form = group[2].to_i
              new_telegram.cloud_height = group[3,2].to_i
            end
          else
            errors << "Ошибка в группе 8 раздела 3"
            return nil
          end
        end
        g_pos = section =~ / 9..../
        if g_pos.present?
          group = section[g_pos+1,5]
          if (group =~/^9[0-9]{4}$/).present?
            new_telegram.weather_data_add = group[1,4].to_i
          else
            errors << "Ошибка в группе 9 раздела 3"
            return nil
          end
        end
      end
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++  
      if pos555.present?
        len = new_telegram.telegram.size-1
        section = new_telegram.telegram[pos555+4,len-pos555-4]
        g_pos = section =~ / 1..../
        if g_pos.present?
          group = section[g_pos+1,5]
          if (group =~ /^1[0-9\/][01][0-9]{2}$/).present?
            if group[1] != '/'
              new_telegram.soil_surface_condition_1 = group[1].to_i
            end
            if group[2] != '/'
              sign = group[2] == '0' ? '' : '-';
              new_telegram.temperature_soil = (sign+group[3,2]).to_i
            end
          else
            errors << "Ошибка в группе 1 раздела 5"
            return nil
          end
        end
        g_pos = section =~ / 3..../
        if g_pos.present?
          group = section[g_pos+1,5]
          if (group =~ /^3[0-9\/][01][0-9]{2}$/).present?
            if group[1] != '/'
              new_telegram.soil_surface_condition_2 = group[1].to_i
            end
            if group[2] != '/'
              sign = group[2] == '0' ? '' : '-';
              new_telegram.temperature_soil_min = (sign+group[3]+'.'+group[4]).to_f
            end
          else
            errors << "Ошибка в группе 3 раздела 5"
            return nil
          end
        end
        g_pos = section =~ / 52.../
        if g_pos.present?
          group = section[g_pos+1,5]
          if (group =~ /^52[01][0-9]{2}$/).present?
            sign = group[2] == '0' ? '' : '-';
            new_telegram.temperature_2cm_min = (sign+group[3,2]).to_i
          else
            errors << "Ошибка в группе 5 раздела 5"
            return nil
          end
        end
        g_pos = section =~ / 6..../
        if g_pos.present?
          group = section[g_pos+1,5]
          if (group =~ /^6[0-9\/]{4}$/).present?
            new_telegram.precipitation_2 = group[1,3].to_i
            new_telegram.precipitation_time_range_2 = group[4]
          else
            errors << "Ошибка в группе 6 раздела 5"
            return nil
          end
        end
      end

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
      stations = Station.all.order(:id)
      full_list.map do |rec|
        {id: rec.id, date: rec.observed_at, term: rec.term, station_name: stations[rec.station_id-1].name, telegram: rec.telegram}
      end
    end
end
