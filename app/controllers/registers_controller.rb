class RegistersController < ApplicationController
  before_filter :find_register, :only => [:show, :edit, :update, :destroy]
  before_filter :find_registers, :only => [:index, :search]
  
  def search
  end
  
  def index
  end
  
  def show
  end
  
  def new
    @register = Register.new
  end
  
  def create
    @register = Register.new register_params
    if not @register.save
      render :new
    else
      redirect_to :registers
    end
  end
  
  def edit
  end

  def update
    if not @register.update_attributes register_params
      render :action => :edit
    else
      redirect_to register_path(@register)
    end
  end
  
  def destroy
    @register.destroy
    redirect_to registers_url, notice: 'Объект удален' 
  end
  
  private

  def find_register
    @register = Register.find(params[:id])
  end
  
  def find_registers
    @registers = Register.all.order(:id)
  end
  
  def register_params
    params.require(:register).permit("Наименнование", "Формуляр", "Инвентарный", "Кабинет", "Ответственный")
  end
end