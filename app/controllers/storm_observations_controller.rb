class StormObservationsController < ApplicationController
  before_filter :find_storm_observation, only: [:show, :edit, :update, :destroy, :update_storm_telegram]

  def get_conversion_params
  end

  def converter
    date_from = params[:interval][:date_from].tr("-", ".")+' 00:00:00'
    date_to = params[:interval][:date_to].tr("-", ".")+' 23:59:59'
    old_telegrams = OldSynopticTelegram.where("Дата >= ? and Дата <= ? and Срок = 'Ш' ", date_from, date_to).order("Дата, Срок")
    stations = Station.station_id_by_code
    selected_telegrams = old_telegrams.size
    wrong_telegrams = 0
    correct_telegrams = 0
    created_telegrams = 0
    updated_telegrams = 0
    skiped_telegrams = 0
    File.open("app/assets/pdf_folder/conversion.txt",'w') do |mylog|
      mylog.puts "Конверсия данных штормовых телеграмм за период с #{date_from} по #{date_to}"
      old_telegrams.each do |t|
        errors = []
        telegram = convert_storm_telegram(t, stations, errors)
        if telegram.present?
          observation = StormObservation.find_by(telegram_date: telegram.telegram_date, station_id: telegram.station_id)
          if observation.present?
            # Rails.logger.debug("My object>>>>>>>>>>>>>>>updated_telegrams: #{hash_telegram.inspect}") 
            if observation.telegram_date.nil? or (observation.telegram_date < telegram.telegram_date) 
              json_telegram = telegram.as_json.except('id', 'created_at', 'updated_at')
              observation.update_attributes json_telegram 
              updated_telegrams += 1
            else
              skiped_telegrams += 1
            end
          else
            observation = StormObservation.new(telegram.as_json)
            observation.save
            created_telegrams += 1
          end
          correct_telegrams += 1
        else
          mylog.puts errors[0]+' => '+t["Дата"]+'->'+t["Телеграмма"]
          wrong_telegrams += 1
        end
      end
      mylog.puts '='*80
      mylog.puts "Всего поступило телеграмм - #{selected_telegrams}"
      mylog.puts "Корректных телеграмм - #{correct_telegrams}: создано - #{created_telegrams}; обновлено - #{updated_telegrams}; пропущено - #{skiped_telegrams}"
      mylog.puts "Ошибочных телеграмм - #{wrong_telegrams}"
    end
    flash[:success] = "Входных телеграмм - #{selected_telegrams}. Корректных телеграмм - #{correct_telegrams} (создано - #{created_telegrams}; обновлено - #{updated_telegrams}; пропущено - #{skiped_telegrams}). Ошибочных телеграмм - #{wrong_telegrams}."
    redirect_to storm_observations_get_conversion_params_path
  end
  
  def search_storm_telegrams
    @date_from ||= params[:date_from].present? ? params[:date_from] : Time.now.strftime("%Y-%m-%d")
    @date_to ||= params[:date_to].present? ? params[:date_to] : Time.now.strftime("%Y-%m-%d")
    station_id = params[:station_code].present? ? Station.find_by_code(params[:station_code]).id : nil
    station = station_id.present? ? " and station_id = #{station_id}" : ''
    text = params[:text].present? ? " and telegram like '%#{params[:text]}%'" : ''
    type = params[:type].present? ? " and telegram_type = '#{params[:type]}'" : ''
       
    sql = "select * from storm_observations where telegram_date >= '#{@date_from}' and telegram_date <= '#{@date_to} 23:59:59' #{station} #{type} #{text} order by telegram_date desc;"
    tlgs = StormObservation.find_by_sql(sql)
    @stations = Station.all.order(:name)
    @stations << {code: 0, name: 'Любая'}
    @telegrams = storm_fields_short_list(tlgs)
    respond_to do |format|
      format.html 
      format.json { render json: {telegrams: @telegrams} }
    end
  end
  
  def storm_fields_short_list(full_list)
    stations = Station.all.order(:id)
    full_list.map do |rec|
      {id: rec.id, date: rec.telegram_date, station_name: stations[rec.station_id-1].name, telegram: rec.telegram}
    end
  end

  def index
    @storm_observations = StormObservation.paginate(page: params[:page]).order(:telegram_date, :created_at).reverse_order
  end
  
  def show
  end
  
  def new
    @storm_observation = StormObservation.new
  end
  
  def input_storm_telegrams
    @stations = Station.all.order(:name)
    @telegrams = StormObservation.short_last_50_telegrams(current_user)
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
    if ret and @storm_observation.save # and synoptic_telegram.save
      flash[:success] = "Создана штормовая телеграмма"
      redirect_to storm_observations_path
    else
      render 'new'
    end
  end
    # Rails.logger.debug("My object>>>>>>>>>>>>>>>: #{telegram.inspect}")
  
  def create_storm_telegram
    date_dev = params[:input_mode] == 'direct' ? Time.parse(params[:date]+' 00:01:00 UTC') : Time.now.utc
    # yyyy_mm = date_dev.year.to_s + '-' + date_dev.month.to_s.rjust(2, '0') + '%'
    # с Н.В. 2018.03.13 согласован интервал в 20 минут
    left_time = date_dev-20.minutes
    sql = "select * from storm_observations where station_id = #{params[:storm_observation][:station_id]} and telegram_type = '#{params[:storm_observation][:telegram_type]}' and day_event = #{params[:storm_observation][:day_event]} and hour_event = #{params[:storm_observation][:hour_event]} and minute_event = #{params[:storm_observation][:minute_event]} and telegram_date > '#{left_time}' order by telegram_date desc"
    telegram = StormObservation.find_by_sql(sql).first
    # telegram = StormObservation.find_by(station_id: params[:storm_observation][:station_id], telegram_type: params[:storm_observation][:telegram_type], day_event: params[:storm_observation][:day_event], hour_event: params[:storm_observation][:hour_event], minute_event: params[:storm_observation][:minute_event])
    # Rails.logger.debug("My object>>>>>>>>>>>>>>>: #{telegram.inspect}")
    if telegram.present?
      if telegram.update_attributes storm_observation_params
        last_telegrams = StormObservation.short_last_50_telegrams(current_user)
        render json: {telegrams: last_telegrams, 
                      tlgType: 'storm', 
                      inputMode: params[:input_mode],
                      currDate: telegram.telegram_date, 
                      errors: ["Телеграмма изменена"]}
      else
        render json: {errors: telegram.errors.messages}, status: :unprocessable_entity
      end
    else
      telegram = StormObservation.new(storm_observation_params)
      telegram.telegram_date = date_dev 
      if telegram.save
        last_telegrams = StormObservation.short_last_50_telegrams(current_user)
        render json: {telegrams: last_telegrams, 
                      tlgType: 'storm', 
                      inputMode: params[:input_mode],
                      currDate: telegram.telegram_date, 
                      errors: ["Телеграмма корректна"]}
      else
        render json: {errors: telegram.errors.messages}, status: :unprocessable_entity
      end
    end
  end
  
  def get_last_telegrams
    # last_telegrams = StormObservation.last_50_telegrams
    # telegrams = fields_short_list(last_telegrams)
    telegrams = StormObservation.short_last_50_telegrams(current_user)
    render json: {telegrams: telegrams, tlgType: 'storm'}
  end
  
  def edit
  end
  
  def update
    if not @storm_observation.update_attributes storm_observation_params
      render :action => :edit
    else
      redirect_to '/storm_observations/input_storm_telegrams'
    end
  end
  
  def update_storm_telegram
    if @storm_observation.update_attributes storm_observation_params
      render json: {errors: []}
    else
      render json: {errors: ["Ошибка при сохранении изменений"]}, status: :unprocessable_entity
    end
  end
  
  def destroy
    @storm_observation.destroy
    flash[:success] = "Удалена штормовая телеграмма"
    redirect_to storm_observations_path
  end
  
  private
    def storm_observation_params
      params.require(:storm_observation).permit(:telegram_type, :station_id, :day_event, :hour_event, :minute_event, :telegram, :telegram_date) #, :code_warep)
      # params.require(:storm_observation).permit(:registred_at, :telegram_type, :station_id, :day_event, :hour_event, :minute_event, :telegram, :telegram_date)
      # :code_warep, :wind_direction, :wind_speed_avg, :wind_speed_max
    end
    
    def find_storm_observation
      @storm_observation = StormObservation.find(params[:id])
    end
    
    def convert_storm_telegram(old_telegram, stations, errors)
      groups = old_telegram["Телеграмма"].tr('=', '').split(' ')
      new_telegram = StormObservation.new
      new_telegram.telegram_date = Time.parse(old_telegram["Дата"]+' UTC')
      new_telegram.telegram = old_telegram["Телеграмма"]
      if (groups[0] == 'ЩЭОЯЮ') or (groups[0] == 'ЩЭОЗМ')
        new_telegram.telegram_type = groups[0]
      else
        errors << "Ошибка в различительной группе"
        return nil
      end
      if groups[1] == 'WAREP'
      else
        errors << "Ошибка в группе WAREP"
        return nil
      end
      code_station = groups[2].to_i
      if stations[code_station].present?
        new_telegram.station_id = stations[code_station]
      else
        errors << "Ошибка в коде станции - <#{code_station}>"
        return nil
      end
      if (groups[3].length == 7) and (groups[3][6] == '1')
        new_telegram.day_event = groups[3][0,2]
        new_telegram.hour_event = groups[3][2,2]
        new_telegram.minute_event = groups[3][4,2]
      else
        errors << "Ошибка в группе времени явления"
        return nil
      end
      new_telegram
    end
    
    # def fields_short_list(full_list)
    #   full_list.map do |rec|
    #     {id: rec.id, date: rec.telegram_date, station_name: rec.station.name, telegram: rec.telegram}
    #   end
    # end
end
