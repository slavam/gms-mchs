class MeteoLinksController < ApplicationController
  before_filter :find_meteo_link, only: [:edit, :update]
  
  def index
    @meteo_links = MeteoLink.all.order(:name)
  end
  
  def new
    @meteo_link = MeteoLink.new
  end
  
  def create
    @meteo_link = MeteoLink.new(meteo_link_params)
    if @meteo_link.save
      redirect_to meteo_links_path
    else
      render 'new'
    end
  end
  
  def edit
  end
  
  def update
    if not @meteo_link.update_attributes meteo_link_params
      render :action => :edit
    else
      redirect_to meteo_links_path
    end
  end
  
  private
    def find_meteo_link
      @meteo_link = MeteoLink.find(params[:id])
    end
    
    def meteo_link_params
      params.require(:meteo_link).permit(:name, :address, :is_active)
    end
  
end
