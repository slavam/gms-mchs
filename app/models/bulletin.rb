class Bulletin < ActiveRecord::Base
  def report_date_as_str
    months = %w{nil января февраля марта апреля мая июня июля августа сентября октября ноября декабря}
    date = self.report_date.to_s(:custom_datetime)
    date[8, 2] + ' ' + months[date[5,2].to_i]+ ' ' + date[0,4] + " года"
  end
  
  def self.synoptic_list
    synnoptics = ["Деревянко Н.Н.", "Осокина Л.Н.", "Николаева А.Р."]
    res = []
    synnoptics.each {|s| res << [s, s]}
    return res
  end
end