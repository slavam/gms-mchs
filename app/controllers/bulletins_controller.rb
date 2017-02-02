class BulletinsController < ApplicationController
  before_filter :find_bulletin, :only => [:show, :destroy, :print_bulletin]
  def index
    @bulletins = Bulletin.all.order(:created_at).reverse_order
  end

  def new
    @bulletin = Bulletin.new
  end
  
  def create
    @bulletin = Bulletin.new(bulletin_params)
    # @bulletin = Factor.new params[:bulletin]
    if not @bulletin.save
      render :new
    else
      redirect_to :bulletins 
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
      params.require(:bulletin).permit(:report_date, :curr_number, :synoptic1, :synoptic2, :storm, :forecast_day, :forecast_period, :forecast_advice, :forecast_orientation, :forecast_sea_day, :forecast_sea_period, :meteo_data, :agro_day_review, :climate_data)
    end
    
    def find_bulletin
      @bulletin = Bulletin.find(params[:id])
    end
end
