class Bulletin < ActiveRecord::Base
  HEAD = "МЧС ДНР
        ГИДРОМЕТЕОРОЛОГИЧЕСКИЙ ЦЕНТР
        МИНИСТЕРСТВА ПО ДЕЛАМ ГРАЖДАНСКОЙ ОБОРОНЫ, ЧРЕЗВЫЧАЙНЫМ
        СИТУАЦИЯМ И ЛИКВИДАЦИИ ПОСЛЕДСТВИЙ СТИХИЙНЫХ БЕДСТВИЙ
        ДОНЕЦКОЙ НАРОДНОЙ РЕСПУБЛИКИ
        (ГИДРОМЕТЦЕНТР МЧС ДНР)"
  ADDRESS = "ул. Любавина, 2, г. Донецк, 83015
        телефон: (062) 304-82-22, телефон/факс: (062) 304-99-25, 
        e-mail: gidromet@mail.dnmchs.ru"
  MONTH_NAME2 = %w{nil января февраля марта апреля мая июня июля августа сентября октября ноября декабря}
  TV_CITIES = ["Артемовск", "Славянск", "Красный Лиман", "Горловка", "Доброполье", "Константиновка", "Красноармейск", "Донецк", "Ясиноватая", "Макеевка", "Снежное", "Шахтерск", "Амвросиевка", "Волноваха", "Марьинка", "Старобешево", "Тельманово", "Мариуполь", "Новоазовск"]
  BULLETIN_TYPES = {'daily' => "Бюллетени ежедневные", 'sea' => "Бюллетени морские", 'holiday' => "Бюллетени выходного дня", 'storm' => "Штормовые предупреждения", 'sea_storm' => "Шторма на море", 'radiation' => "Радиация", 'tv' => "Телевидение"}

  mount_uploader :picture, PictureUploader
  def pdf_filename(user_id)
    "Bulletin_#{self.bulletin_type}_#{user_id}.pdf"
  end
  
  def png_filename(user_id)
    "Bulletin_#{self.bulletin_type}_#{user_id}.png"
  end

  def png_page_filename(user_id, page)
    "Bulletin_#{self.bulletin_type}_#{user_id}-#{page}.png"
  end

  def report_date_as_str
    date = self.report_date.to_s(:custom_datetime)
    date[8, 2] + ' ' + MONTH_NAME2[date[5,2].to_i]+ ' ' + date[0,4] + " года"
  end
  
  def self.synoptic_list
    synoptics = ["Деревянко Н.Н.", "Маренкова Н.В.", "Осокина Л.Н.", "Соколова Т.Е.", "Щербак Е.Д.", "Николаева А.Р."]
    res = []
    synoptics.each {|s| res << [s, s]}
    return res
  end
  
  def date_hour_minute
    report_date = self.report_date.to_s
    "#{report_date[8,2]}.#{report_date[5,2]}.#{report_date[0,4]} г. #{self.storm_hour} час. #{self.storm_minute == 0 ? '00' : self.storm_minute} мин."
  end
end