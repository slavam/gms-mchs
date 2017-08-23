class SynopticObservationsController < ApplicationController
  # before_filter :require_observer_or_technicist
  before_filter :find_synoptic_observation, only: [:show, :update_synoptic_telegram] 
  
  def search_synoptic_telegrams
    @date ||= params[:date].present? ? params[:date] : Time.now.strftime("%Y-%m-%d")
    term = params[:term].present? ? " and term = #{params[:term]}" : ''
    station_id = params[:station_code].present? ? Station.find_by_code(params[:station_code]).id : nil
    station = station_id.present? ? " and station_id = #{station_id}" : ''
    text = params[:text].present? ? " and telegram like '%#{params[:text]}%'" : ''
       
    sql = "select * from synoptic_observations where date like '#{@date}' #{term} #{station} #{text};"
    tlgs = SynopticObservation.find_by_sql(sql)
    @stations = Station.all.order(:name)
    @stations << {code: 0, name: 'Любая'}
    @telegrams = fields_short_list(tlgs)
    respond_to do |format|
      format.html 
      format.json { render json: {telegrams: @telegrams} }
    end
  end
  
  def show
  end
  
  def new
    # @date = Time.now.to_s(:simple_date_time)
    # Rails.logger.debug("My object>>>>>>>>>>>>>>>: #{current_user.inspect}")
    @stations = Station.all.order(:name)
    last_telegrams = SynopticObservation.last_50_telegrams
    @last_telegrams = fields_short_list(last_telegrams)
  end
  
  def create_synoptic_telegram
    telegram = SynopticObservation.new(observation_params)
    telegram.station_id = Station.find_by_code(params[:station_code]).id
    # Rails.logger.debug("My object>>>>>>>>>>>>>>>: #{current_user.inspect}")
    if telegram.save
      telegrams = SynopticObservation.last_50_telegrams
      last_telegrams = fields_short_list(telegrams)
      render json: {telegrams: last_telegrams}
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
  private
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
    
    def require_observer_or_technicist
      if current_user and ((current_user.role == 'observer') || (current_user.role == 'technicist'))
      else
        flash[:danger] = 'Вход только для наблюдателей'
        redirect_to login_path
        return false
      end
    end
    
    def fields_short_list(full_list)
      full_list.map do |rec|
        {id: rec.id, date: rec.date, term: rec.term, station_name: rec.station.name, telegram: rec.telegram}
      end
    end
end
