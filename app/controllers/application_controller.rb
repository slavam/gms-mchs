class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  def month_name month_num
    months = %w{nil январь февраль март апрель май июнь июль август сентябрь октябрь ноябрь декабрь}
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
  
  helper_method :month_name, :station_name
  
end
