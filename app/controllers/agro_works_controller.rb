class AgroWorksController < ApplicationController
  def index
    @agro_works = AgroWork.all.order(:code)
  end
  
  def new
    @agro_work = AgroWork.new
  end
  
  def create
    @agro_work = AgroWork.new(agro_work_params)
    if @agro_work.save
      flash[:success] = "Создана работа"
      redirect_to agro_works_path
    else
      render 'new'
    end
  end
  
  private
    def agro_work_params
      params.require(:agro_work).permit(:name, :code)
    end
end
