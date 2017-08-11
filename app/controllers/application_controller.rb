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
  
  helper_method :month_name, :month_name2, :station_name
  
end
