class AgroDamagesController < ApplicationController
  def index
    @agro_damages = AgroDamage.all.order(:code)
  end
  
  def new
    @agro_damage = AgroDamage.new
  end
  
  def create
    @agro_damage = AgroDamage.new(agro_damage_params)
    if @agro_damage.save
      flash[:success] = "Создано описание повреждения"
      redirect_to agro_damages_path
    else
      render 'new'
    end
  end
  
  private
    def agro_damage_params
      params.require(:agro_damage).permit(:name, :code)
    end
end
