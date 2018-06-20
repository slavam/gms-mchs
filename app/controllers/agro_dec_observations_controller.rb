class AgroDecObservationsController < ApplicationController
  before_filter :find_agro_dec_observation, only: [:show, :update_agro_dec_telegram]
  
  def index
    @agro_dec_observations = AgroDecObservation.paginate(page: params[:page]).order(:date_dev, :created_at).reverse_order
  end
  
  def show
  end
  
  def search_agro_dec_telegrams
    @date_from ||= params[:date_from].present? ? params[:date_from] : Time.now.strftime("%Y-%m-%d")
    @date_to ||= params[:date_to].present? ? params[:date_to] : Time.now.strftime("%Y-%m-%d")
    station_id = params[:station_code].present? ? Station.find_by_code(params[:station_code]).id : nil
    station = station_id.present? ? " and station_id = #{station_id}" : ''
    text = params[:text].present? ? " and telegram like '%#{params[:text]}%'" : ''
       
    sql = "select * from agro_dec_observations where date_dev >= '#{@date_from}' and date_dev <= '#{@date_to} 23:59:59' #{station} #{text} order by date_dev desc;"
    tlgs = AgroDecObservation.find_by_sql(sql)
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
  
  def create_agro_dec_telegram
    telegram_text = params[:agro_dec_observation][:telegram]
    station_id = params[:agro_dec_observation][:station_id]
    date_dev = params[:input_mode] == 'direct' ? Time.parse(params[:date]+' 00:01:00 UTC') : Time.now
    # telegram_type = telegram_text[0,5]
    day_obs = telegram_text[12,2].to_i
    month_obs = telegram_text[14,2].to_i
    telegram_num = telegram_text[16,1].to_i
    yyyy_mm = date_dev.year.to_s + '-' + date_dev.month.to_s.rjust(2, '0') + '%'

    telegram = AgroDecObservation.where("station_id = ? and day_obs = ? and month_obs = ? and telegram_num = ? and date_dev like ?", station_id, day_obs, month_obs, telegram_num, yyyy_mm).order(:date_dev).reverse_order.first
    if telegram.present? 
      if telegram.update_attributes agro_dec_observation_params
        params[:crop_dec_conditions].each do |k, v|
          c_c = CropDecCondition.find_by(agro_dec_observation_id: telegram.id, crop_code: v[:crop_code].to_i)
          if c_c.present?
            c_c.update_attributes crop_dec_conditions_params(v)
          else
            telegram.crop_dec_conditions.build(crop_dec_conditions_params(v)).save
          end
        end if params[:crop_dec_conditions].present?
        last_telegrams = AgroDecObservation.short_last_50_telegrams(current_user)
        render json: {telegrams: last_telegrams, 
                      tlgType: 'agro_dec', 
                      inputMode: params[:input_mode],
                      currDate: date_dev, 
                      errors: ["Телеграмма изменена"]}
      else
        render json: {errors: telegram.errors.messages}, status: :unprocessable_entity
      end
    else
      telegram = AgroDecObservation.new(agro_dec_observation_params)
      telegram.date_dev = date_dev
      telegram.day_obs = day_obs
      telegram.month_obs = month_obs
      telegram.telegram_num = telegram_num
      telegram.telegram = telegram_text
      if telegram.save
        params[:crop_dec_conditions].each do |k, v|
          telegram.crop_dec_conditions.build(crop_dec_conditions_params(v)).save
        end if params[:crop_dec_conditions].present?
        last_telegrams = AgroDecObservation.short_last_50_telegrams(current_user)
        render json: {telegrams: last_telegrams, 
                      tlgType: 'agro_dec', 
                      inputMode: params[:input_mode],
                      currDate: date_dev, 
                      errors: ["Телеграмма корректна"]}
      else
        render json: {errors: telegram.errors.messages}, status: :unprocessable_entity
      end
    end
  end
  
  def input_agro_dec_telegrams
    @stations = Station.all.order(:name)
    @telegrams = AgroDecObservation.short_last_50_telegrams(current_user)
  end
  
  def get_last_telegrams
    telegrams = AgroDecObservation.short_last_50_telegrams(current_user)
    render json: {telegrams: telegrams, tlgType: 'agro_dec'}
  end
  
  def update_agro_dec_telegram
# Rails.logger.debug("My object>>>>>>>>>>>>>>>updated_telegrams: #{params[:agro_observation][:telegram].inspect}") 
    if @agro_dec_observation.update_attributes agro_dec_observation_params
      params[:crop_dec_conditions].each do |k, v|
        c_c = CropDecCondition.find_by(agro_dec_observation_id: @agro_dec_observation.id, crop_code: v[:crop_code].to_i)
        if c_c.present?
          c_c.update_attributes crop_dec_conditions_params(v)
        else
          @agro_observation.crop_dec_conditions.build(crop_dec_conditions_params(v)).save
        end
      end if params[:crop_dec_conditions].present?
      render json: {errors: []}
    else
      render json: {errors: ["Ошибка при сохранении изменений"]}, status: :unprocessable_entity
    end
  end
  
  private
    def find_agro_dec_observation
      @agro_dec_observation = AgroDecObservation.find(params[:id])
    end
    
    def crop_dec_conditions_params(crop_dec_condition)
      crop_dec_condition.permit(:agro_dec_observation_id, :crop_code, :plot_code, :agrotechnology, :development_phase_1, 
        :development_phase_2, :development_phase_3, :development_phase_4, :development_phase_5, :day_phase_1, :day_phase_2, 
        :day_phase_3, :day_phase_4, :day_phase_5, :assessment_condition_1, :assessment_condition_2, :assessment_condition_3, 
        :assessment_condition_4, :assessment_condition_5, :clogging_weeds, :height_plants, :number_plants, :average_mass, 
        :agricultural_work_1, :agricultural_work_2, :agricultural_work_3, :agricultural_work_4, :agricultural_work_5, 
        :day_work_1, :day_work_2, :day_work_3, :day_work_4, :day_work_5, :damage_plants_1, :damage_plants_2, :damage_plants_3, 
        :damage_plants_4, :damage_plants_5, :day_damage_1, :day_damage_2, :day_damage_3, :day_damage_4, :day_damage_5, 
        :damage_level_1, :damage_level_2, :damage_level_3, :damage_level_4, :damage_level_5, :damage_volume_1, :damage_volume_2, 
        :damage_volume_3, :damage_volume_4, :damage_volume_5, :damage_space_1, :damage_space_2, :damage_space_3, :damage_space_4, 
        :damage_space_5, :number_spicas, :num_bad_spicas, :number_stalks, :stalk_with_spike_num, :normal_size_potato, :losses, 
        :grain_num, :bad_grain_percent, :bushiness, :shoots_inflorescences, :grain1000_mass, :moisture_reserve_10, :moisture_reserve_5, 
        :soil_index, :moisture_reserve_2, :moisture_reserve_1, :temperature_water_2, :depth_water, :depth_groundwater, 
        :depth_thawing_soil, :depth_soil_wetting, :height_snow_cover, :snow_retention, :snow_cover, :snow_cover_density, 
        :number_measurements_0, :number_measurements_3, :number_measurements_30, :ice_crust, :thickness_ice_cake, :depth_thawing_soil_2, 
        :depth_soil_freezing, :thaw_days, :thermometer_index, :temperature_dec_min_soil3, :height_snow_cover_rail, :viable_method, 
        :soil_index_2, :losses_1, :losses_2, :losses_3, :losses_4, :temperature_dead50)
    end

    def agro_dec_observation_params
      params.require(:agro_dec_observation).permit(:date_dev, :day_obs, :month_obs, :telegram, :station_id, :telegram_num, 
        :temperature_dec_avg_delta, :temperature_dec_avg, :temperature_dec_max, :hot_dec_day_num, :temperature_dec_min, 
        :dry_dec_day_num, :temperature_dec_min_soil, :cold_soil_dec_day_num, :precipitation_dec, :wet_dec_day_num, 
        :precipitation_dec_percent, :wind_speed_dec_max, :wind_speed_dec_max_day_num, :duster_dec_day_num, :temperature_dec_max_soil, 
        :sunshine_duration_dec, :freezing_dec_day_num, :temperature_dec_avg_soil10, :temperature25_soil10_dec_day_num, :dew_dec_day_num, 
        :saturation_deficit_dec_avg, :relative_humidity_dec_avg, :percipitation_dec_max, :percipitation5_dec_day_num)
    end
end
