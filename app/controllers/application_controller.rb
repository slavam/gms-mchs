class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :exception
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format.json? }
  include SessionsHelper
  Time::DATE_FORMATS[:custom_datetime] = "%Y.%m.%d"
  Time::DATE_FORMATS[:custom_printdate] = "%d.%m.%Y"
  
  
  def month_name month_num
    months = %w{nil январь февраль март апрель май июнь июль август сентябрь октябрь ноябрь декабрь}
    months[month_num.to_i]
  end
  
  def month_name2 month_num
    months = %w{nil января февраля марта апреля мая июня июля августа сентября октября ноября декабря}
    months[month_num.to_i]
  end
  
  def station_name station_code
    case station_code
      when "34622"
        "Амвросиевка"
      when "34524"
        "Дебальцево"
      when "34519"
        "Донецк"
      when "34615"
        "Волноваха"
      when "34712"
        "Мариуполь"
      when "34523"
        "Луганск"
      when "34510"
        "Артемовск"
      when "34514"
        "Красноармейск"        
      else
        ""
    end
  end
  
  def calc_concentration(measurement, material_id, optical_density)
    post = Post.find(measurement.post_id)
    laboratory_id = post.laboratory_id
    chem_coefficient = ChemCoefficient.find_by(material_id: material_id, laboratory_id: laboratory_id)
    if chem_coefficient.nil? 
      return optical_density # nil
    end
    t_kelvin = measurement.temperature + 273.0
    pressure = measurement.atmosphere_pressure / 1.334 # гигапаскали -> мм. рт. ст
    if material_id == 1 # пыль
      v_normal = pressure/t_kelvin*0.359*post.sample_volume_dust
      return optical_density/v_normal*1000 # м куб -> дм куб
    end
    v_normal = pressure/t_kelvin*0.359*chem_coefficient.sample_volume
    m = optical_density*chem_coefficient.calibration_factor
    con = (m*chem_coefficient.solution_volume)/(v_normal*chem_coefficient.aliquot_volume)
    return con
  end
  
  # def get_digits(n)
  #   ndigits = []
  #   ndigits[1] = 2
  #   ndigits[2] = 3
  #   ndigits[4] = 0
  #   ndigits[5] = 2
  #   ndigits[6] = 2
  #   ndigits[10] = 3
  #   ndigits[19] = 2
  #   ndigits[22] = 3
  #   return ndigits[n] || 2
  # end
  
  helper_method :month_name, :month_name2, :station_name
  
end
