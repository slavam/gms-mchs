class AgroObservationsController < ApplicationController
  before_filter :find_agro_observation, only: [:show, :update_agro_telegram]
  
  def index
    @agro_observations = AgroObservation.paginate(page: params[:page]).order(:date_dev, :created_at).reverse_order
  end
  
  def show
  end
  
  def search_agro_telegrams
    @date_from ||= params[:date_from].present? ? params[:date_from] : Time.now.strftime("%Y-%m-%d")
    @date_to ||= params[:date_to].present? ? params[:date_to] : Time.now.strftime("%Y-%m-%d")
    station_id = params[:station_code].present? ? Station.find_by_code(params[:station_code]).id : nil
    station = station_id.present? ? " and station_id = #{station_id}" : ''
    text = params[:text].present? ? " and telegram like '%#{params[:text]}%'" : ''
       
    sql = "select * from agro_observations where date_dev >= '#{@date_from}' and date_dev <= '#{@date_to} 23:59:59' #{station} #{text} order by date_dev desc;"
    tlgs = AgroObservation.find_by_sql(sql)
    @stations = Station.all.order(:name)
    @stations << {code: 0, name: 'Любая'}
    @telegrams = agro_fields_short_list(tlgs)
    respond_to do |format|
      format.html 
      format.json { render json: {telegrams: @telegrams} }
    end
  end
  
  def agro_fields_short_list(full_list)
    stations = Station.all.order(:id)
    full_list.map do |rec|
      {id: rec.id, date: rec.date_dev, station_name: stations[rec.station_id-1].name, telegram: rec.telegram}
    end
  end
  
  def new
    @agro_observation = AgroObservation.new
    @agro_observation.date_dev = Time.now
  end
  
  def create
    @agro_observation = AgroObservation.new(agro_observation_params)
    tlg_as_array = @agro_observation.telegram.split(' ')
    @agro_observation.day_obs = tlg_as_array[2][0,2].to_i
    @agro_observation.month_obs = tlg_as_array[2][2,2].to_i
    # Rails.logger.debug("My object>>>>>>>>>>>>>>>: #{tlg_as_array.inspect}")
    ret = true
    if @agro_observation.telegram_type != @agro_observation.telegram[0,5]
      flash[:danger] = 'Ошибка в типе телеграммы'
      ret = false
    end
    if ret and @agro_observation.save
      flash[:success] = "Создана агро-телеграмма"
      redirect_to agro_observations_path
    else
      render 'new'
    end
  end
  
  def create_agro_telegram
    telegram_text = params[:agro_observation][:telegram]
    station_id = params[:agro_observation][:station_id]
    date_dev = params[:input_mode] == 'direct' ? Time.parse(params[:date]+' 00:01:00 UTC') : Time.now
    telegram_type = telegram_text[0,5]
    day_obs = telegram_text[12,2].to_i
    month_obs = telegram_text[14,2].to_i
    telegram_num = telegram_text[16,1].to_i
    yyyy_mm = date_dev.year.to_s + '-' + date_dev.month.to_s.rjust(2, '0') + '%'

    # telegram = AgroObservation.find_by( station_id: station_id, 
    #                                     telegram_type: telegram_type, 
    #                                     day_obs: day_obs, 
    #                                     month_obs: month_obs, 
    #                                     telegram_num: telegram_num)
    telegram = AgroObservation.where("telegram_type = ? and station_id = ? and day_obs = ? and month_obs = ? and telegram_num = ? and date_dev like ?", telegram_type, station_id, day_obs, month_obs, telegram_num, yyyy_mm).order(:date_dev).reverse_order.first
    if telegram.present? # and (telegram.date_dev.year == date_dev.year) and (telegram.date_dev.month == date_dev.month)
      if telegram.update_attributes agro_observation_params
        params[:crop_conditions].each do |k, v|
          c_c = CropCondition.find_by(agro_observation_id: telegram.id, crop_code: v[:crop_code].to_i)
          if c_c.present?
            c_c.update_attributes crop_conditions_params(v)
          else
            telegram.crop_conditions.build(crop_conditions_params(v)).save
          end
        end if params[:crop_conditions].present?
        params[:crop_damages].each do |k, v|
          c_d = CropDamage.find_by(agro_observation_id: telegram.id, crop_code: v[:crop_code].to_i)
          if c_d.present?
            c_d.update_attributes crop_damages_params(v)
          else
            telegram.crop_damages.build(crop_damages_params(v)).save
          end
        end if params[:crop_damages].present?
        last_telegrams = AgroObservation.short_last_50_telegrams(current_user)
        render json: {telegrams: last_telegrams, 
                      tlgType: 'agro', 
                      inputMode: params[:input_mode],
                      currDate: date_dev, 
                      errors: ["Телеграмма изменена"]}
      else
        render json: {errors: telegram.errors.messages}, status: :unprocessable_entity
      end
    else
      telegram = AgroObservation.new(agro_observation_params)
      telegram.date_dev = date_dev
      telegram.telegram_type = telegram_type
      telegram.day_obs = day_obs
      telegram.month_obs = month_obs
      telegram.telegram_num = telegram_num
      telegram.telegram = telegram_text
      if telegram.save
        params[:crop_conditions].each do |k, v|
          telegram.crop_conditions.build(crop_conditions_params(v)).save
        end if params[:crop_conditions].present?
        params[:crop_damages].each do |k, v|
          telegram.crop_damages.build(crop_damages_params(v)).save
        end if params[:crop_damages].present?
        last_telegrams = AgroObservation.short_last_50_telegrams(current_user)
        render json: {telegrams: last_telegrams, 
                      tlgType: 'agro', 
                      inputMode: params[:input_mode],
                      currDate: date_dev, 
                      errors: ["Телеграмма корректна"]}
      else
        render json: {errors: telegram.errors.messages}, status: :unprocessable_entity
      end
    end
  end
  
  def input_agro_telegrams
    @stations = Station.all.order(:name)
    @telegrams = AgroObservation.short_last_50_telegrams(current_user)
  end
  
  def get_last_telegrams
    telegrams = AgroObservation.short_last_50_telegrams(current_user)
    render json: {telegrams: telegrams, tlgType: 'agro'}
  end
  
  def update_agro_telegram
# Rails.logger.debug("My object>>>>>>>>>>>>>>>updated_telegrams: #{params[:agro_observation][:telegram].inspect}") 
    if @agro_observation.update_attributes agro_observation_params
      params[:crop_conditions].each do |k, v|
          c_c = CropCondition.find_by(agro_observation_id: @agro_observation.id, crop_code: v[:crop_code].to_i)
          if c_c.present?
            c_c.update_attributes crop_conditions_params(v)
          else
            @agro_observation.crop_conditions.build(crop_conditions_params(v)).save
          end
        end if params[:crop_conditions].present?
        params[:crop_damages].each do |k, v|
          c_d = CropDamage.find_by(agro_observation_id: @agro_observation.id, crop_code: v[:crop_code].to_i)
          if c_d.present?
            c_d.update_attributes crop_damages_params(v)
          else
            @agro_observation.crop_damages.build(crop_damages_params(v)).save
          end
        end if params[:crop_damages].present?
      render json: {errors: []}
    else
      render json: {errors: ["Ошибка при сохранении изменений"]}, status: :unprocessable_entity
    end
  end
  
  private

    def crop_conditions_params(crop_condition)
      crop_condition.permit(:crop_code, :development_phase_1, :development_phase_2, :development_phase_3, 
        :development_phase_4, :development_phase_5, :assessment_condition_1, :assessment_condition_2, :assessment_condition_3, 
        :assessment_condition_4, :assessment_condition_5, :agricultural_work_1, :agricultural_work_2, :agricultural_work_3,
        :agricultural_work_4, :agricultural_work_5, :index_weather_1, :index_weather_2, :index_weather_3, :index_weather_4,
        :index_weather_5, :damage_plants_1, :damage_plants_2, :damage_plants_3, :damage_plants_4, :damage_plants_5, :damage_volume_1,
        :damage_volume_2, :damage_volume_3, :damage_volume_4, :damage_volume_5)
    end
    
    def crop_damages_params(crop_damage)
      crop_damage.permit(:crop_code, :height_snow_cover_rail, :depth_soil_freezing, :thermometer_index, :temperature_dec_min_soil3)
    end
    
    def agro_observation_params
      params.require(:agro_observation).permit(:telegram_type, :station_id, :date_dev, :day_obs, :month_obs, :telegram_num, :telegram,
       :temperature_max_12, :temperature_avg_24, :temperature_min_24, :temperature_min_soil_24, :percipitation_24, :percipitation_type,
       :percipitation_12, :wind_speed_max_24, :saturation_deficit_max_24, :duration_dew_24, :dew_intensity_max, :dew_intensity_8,
       :sunshine_duration_24, :state_top_layer_soil, :temperature_field_5_16, :temperature_field_10_16, :temperature_avg_soil_5,
       :temperature_avg_soil_10, :saturation_deficit_avg_24, :relative_humidity_min_24)
      # :crop_conditions, crop_damages
    end
    
    def find_agro_observation
      @agro_observation = AgroObservation.find(params[:id])
    end
    
    def fields_short_list(full_list)
      full_list.map do |rec|
        {id: rec.id, date: rec.date_dev, station_name: rec.station.name, telegram: rec.telegram}
      end
    end
end
