class BulletinsController < ApplicationController
  before_filter :find_bulletin, :only => [:show, :destroy, :print_bulletin, :edit, :update]
  def index
    @bulletins = Bulletin.all.order(:created_at).reverse_order
  end

  def new
    @bulletin = Bulletin.new
    @bulletin.report_date = Time.now.to_s(:custom_datetime)
    @bulletin.curr_number = Date.today.yday()
  end
  
  def create
    @bulletin = Bulletin.new(bulletin_params)
    @bulletin.meteo_data = ''
    (1..27).each do |i|
      @bulletin.meteo_data += params["val_#{i}"]+'; '
    end
    @bulletin.climate_data = params[:avg_day_temp] + '; ' + params[:max_temp] + '; '+ params[:max_temp_year] + '; ' + params[:min_temp] + '; '+ params[:min_temp_year] + '; '
    if not @bulletin.save
      render :new
    else
      redirect_to :bulletins 
    end
  end
  
  def edit
  end

  def update
    if not @bulletin.update_attributes bulletin_params
      render :action => :edit
    else
      redirect_to bulletin_path(@bulletin)
    end
  end

  def destroy
    @bulletin.destroy
    redirect_to bulletins_path
  end

  def show
  end
  
  def print_bulletin
  end
  
  private
  
    def bulletin_params
      params.require(:bulletin).permit(:report_date, :curr_number, :duty_synoptic, :synoptic1, :synoptic2, :storm, :forecast_day, :forecast_day_city, :forecast_period, :forecast_advice, :forecast_orientation, :forecast_sea_day, :forecast_sea_period, :meteo_data, :agro_day_review, :climate_data)
    end
    
    def find_bulletin
      @bulletin = Bulletin.find(params[:id])
    end
end
