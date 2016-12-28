class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  def month_name month_num
    months = %w{nil январь февраль март апрель май июнь июль август сентябрь октябрь ноябрь декабрь}
    months[month_num.to_i]
  end
  
  helper_method :month_name
  
end
