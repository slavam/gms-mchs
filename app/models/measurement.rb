class Measurement < ActiveRecord::Base
  belongs_to :post
  has_many :pollution_values, :dependent => :destroy
  
  def self.get_id_by_date_term_post(date, term, post)
    ms = Measurement.where("date = ? AND term = ? AND post_id = ?", date, term, post)
    if ms.count == 0
      return nil
    else
      return ms[0].id
    end
  end
  
  def concentrations_by_measurement
    pollutions = PollutionValue.find_by_sql("SELECT p_v.id id, p_v.material_id material_id, p_v.value value, p_v.concentration concentration, ma.name name FROM pollution_values p_v INNER JOIN materials ma ON ma.id = p_v.material_id WHERE p_v.measurement_id = #{self.id} ORDER BY p_v.material_id")
    concentrations = {}
    pollutions.each {|p|
      concentrations[p.material_id] = {id: p.id, material_name: p.name, value: p.value, concentration: p.concentration.round(4)}
    }
    return concentrations
  end
  
  def get_weather
    weather = {}
    weather[:wind_speed] = self.wind_speed
    weather[:wind_direction] = self.wind_direction
    weather[:temperature] = self.temperature
    weather[:atmosphere_pressure] = self.atmosphere_pressure
    weather
  end
end
