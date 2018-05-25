class PollutionValuesController < ApplicationController
  before_filter :find_pollution_value, only: [:destroy, :edit, :update, :delete_value]

  def edit
  end

  def update
    optical_density = params[:pollution_value][:value].to_f
    concentration = (optical_density.nil? ? nil : calc_concentration(@pollution_value.measurement, @pollution_value.material_id, optical_density))
    if not @pollution_value.update(value: optical_density, concentration: concentration)
      render :action => :edit
    else
      redirect_to measurements_path
    end
  end
  
  def delete_value
    master_record_id = @pollution_value.measurement_id
    @pollution_value.destroy
    concentrations = Measurement.find(master_record_id).concentrations_by_measurement
    render :json => { :errors => ["Удалена запись о загрязнении"], concentrations: concentrations }
  end
  
  def destroy
    @pollution_value.destroy
    flash[:success] = "Загрязнение удалено"
    redirect_to measurements_path
  end
  
  private
    def pollution_value_params
      params.require(:pollution_value).permit(:value, :concentration)
    end
    
    def find_pollution_value
      @pollution_value = PollutionValue.find(params[:id])
    end
    
    # def calc_concentration(measurement, material_id, optical_density)
    #   post = Post.find(measurement.post_id)
    #   laboratory_id = post.laboratory_id
    #   chem_coefficient = ChemCoefficient.find_by(material_id: material_id, laboratory_id: laboratory_id)
    #   if chem_coefficient.nil? 
    #     return optical_density # nil
    #   end
    #   t_kelvin = measurement.temperature + 273.0
    #   pressure = measurement.atmosphere_pressure / 1.334 # гигапаскали -> мм. рт. ст
    #   if material_id == 1 # пыль
    #     v_normal = pressure/t_kelvin*0.359*post.sample_volume_dust
    #     return optical_density/v_normal*1000 # м куб -> дм куб
    #   end
    #   v_normal = pressure/t_kelvin*0.359*chem_coefficient.sample_volume
    #   m = optical_density*chem_coefficient.calibration_factor
    #   con = (m*chem_coefficient.solution_volume)/(v_normal*chem_coefficient.aliquot_volume)
    #   return con
    # end

end
