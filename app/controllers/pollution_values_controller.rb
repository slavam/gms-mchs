class PollutionValuesController < ApplicationController
  before_filter :find_pollution_value, only: [:destroy, :edit, :update]

  def edit
  end

  def update
    if not @pollution_value.update_attributes pollution_value_params
      render :action => :edit
    else
      redirect_to measurements_path
    end
  end
  
  def destroy
    @pollution_value.destroy
    flash[:success] = "Концентрация удалена"
    redirect_to measurements_path
  end
  
  private
    def pollution_value_params
      params.require(:pollution_value).permit(:value)
    end
    def find_pollution_value
      @pollution_value = PollutionValue.find(params[:id])
    end
end
