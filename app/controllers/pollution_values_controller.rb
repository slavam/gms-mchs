class PollutionValuesController < ApplicationController
  before_filter :find_pollution_value, only: [:destroy, :edit, :update, :delete_value]

  def edit
  end

  def update
    if not @pollution_value.update_attributes pollution_value_params
      render :action => :edit
    else
      redirect_to measurements_path
    end
  end
  
  def delete_value
    master_record_id = @pollution_value.measurement_id
    @pollution_value.destroy
    concentrations = Measurement.find(master_record_id).concentrations_by_measurement
    render :json => { :errors => ["Удалена запись о концентрации"], concentrations: concentrations }
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
