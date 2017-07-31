# require 'net/http'
# require 'uri'
# require 'open-uri'
# class Synoptic < Meteo  
class Synoptic < ActiveRecord::Base
  self.table_name = 'sinop'
  TERMS = ['00', '03', '06', '09', '12', '15', '18', '21']
  MASTER_TERMS = ['00', '06', '12', '18']
  SLAVE_TERMS = ['03', '09', '15', '21']
  HEADERS = ["ЩЭСМЮ" ,"ЩЭСИД"] #, "WAREP"]
  validate :synoptic_telegramm_check
  
  def term_valid?
    TERMS.include?(self["Срок"])
  end
  
  def group0_valid?
    HEADERS.include?(self["Телеграмма"][0,5])
  end
  
  def term_group0_satisfy?
    gr0 = self["Телеграмма"][0,5]
    (("ЩЭСМЮ" == gr0) and MASTER_TERMS.include?(gr0)) or (("ЩЭСИД" == gr0) and SLAVE_TERMS.include?(gr0))
  end
  
  def temp_to_s
    if self["Телеграмма"].split(' ').size > 4
      s = self["Телеграмма"].split(' ')[4]
      if s.length > 4
        sign = s[1] == '0' ? '' : '-'
        sign+s[2,2]+'.'+s[4]
      else
        s
      end
    # else
    #   self["Телеграмма"]
    end
  end
  
  def station_name
    case self["Телеграмма"].split(' ')[1]
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
        self["Телеграмма"].split(' ')[1]
    end
  end
  
  def get_pressure
    a_p = get_group(1, '3').to_s.strip
    if a_p.present?
      first = (a_p[1] == '0')? '1' : ''
      return (first + a_p[1,3] + '.' + a_p[4]).to_f
    else
      return nil
    end
  end
  
  def get_temperature
    t = self["Телеграмма"].split(' ')
    if t.size > 4
      s = t[4]
      sign = s[1] == '0' ? '' : '-'
      return (sign+s[2,2]+'.'+s[4]).to_f
    else
      return nil
    end
  end
  
  def get_wind_direction
    self["Телеграмма"].split(' ')[3][1,2].to_i
  end
  
  def get_rhumb_4
    direct = self["Телеграмма"].split(' ')[3][1,2].to_i
    case direct
      when 5..13
        'east'
      when 14..22
        'south'
      when 23..31
        'west'
      else
        'north'
    end
  end
  
  def wind_direct
    direct = self["Телеграмма"].split(' ')[3][1,2].to_i
    case direct
      when 0
        "Штиль"
      when 1..2
        "Ветер северо-северо-восточный"
      when 3..5
        "Ветер северо-восточный"
      when 6..7
        "Ветер восточно-северо-восточный"
      when 8..9
        "Ветер восточный"
      when 10..11
        "Ветер восточно-юго-восточный"
      when 12..14
        "Ветер юго-восточный"
      when 15..16
        "Ветер юго-юго-восточный"
      when 17..18
        "Ветер южный"
      when 19..20
        "Ветер юго-юго-западный"
      when 21..23
        "Ветер юго-западный"
      when 24..25
        "Ветер западно-юго-западный"
      when 26..27
        "Ветер западный"
      when 28..29
        "Ветер западно-северо-западный"
      when 30..32
        "Ветер северо-западный"
      when 33..34
        "Ветер северо-северо-западный"
      when 35..36
        "Ветер северный"
      when 99
        "Ветер переменный"
      else
        direct
    end
  end
  
  def wind_speed
    self["Телеграмма"].split(' ')[3][3,2].to_i
  end
  
  def visibility
    vis = self["Телеграмма"].split(' ')[2][3,2].to_i
    case vis
      when 90
        " менее 50 метров"
      when 91
        " 50 метров"
      when 92
        " 200 метров"
      when 93
        " 500 метров"
      when 94 
        " 1 километр"
      when 95 
        " 2 километра"
      when 96
        " 4 километра"
      when 97
        " 10 километров"
      when 98
        " 20 километров"
      when 99
        " более 50 километров"
      else
        vis
    end
  end
  
  def cloudiness
    c = self["Телеграмма"].split(' ')[3][0]
    case c
      when '0'
        "Облаков нет"
      when '1'
        '<=1 (но не 0)'
      when '2'
        '2-3'
      when '3'
        '4'
      when '4'
        '5'
      when '5'
        '6'
      when '6'
        '7-8'
      when '7'
        '>= 9 (но не 10, есть просветы)'
      when '8'
        '10 (без просветов)'
      when '9'
        'Определить невозможно (затруднена видимость)'
      when '/'
        'Определить невозможно (наблюдения не проводились)'
    end
  end
  
  def cloud_base
    c_b = self["Телеграмма"].split(' ')[2][2]
    case c_b
      when '0'
        "<50"
      when '1'
        "50-100"
      when '2'
        "100-200"
      when '3'
        "200-300"
      when '4'
        "300-600"
      when '5'
        "600-1000"
      when '6'
        "1000-1500"
      when '7'
        "1500-2000"
      when '8'
        "2000-2500"
      when '9'
        ">2500"
      when  '/'
        " нижняя граница не определенна"
    end
  end
  
  def air_temperature
    a_t = get_group(1, '1').to_s.strip
    if a_t.present?
      sign = (a_t[1] == '0')? '' : '-'
      return sign + a_t[2,2] + ',' + a_t[4] + '°'
    else
      return nil
    end
  end
  
  def dew_point
    d_p = get_group(1, '2').to_s.strip
    if d_p.present?
      sign = (d_p[1] == '0')? '' : '-'
      return sign + d_p[2,2] + ',' + d_p[4] + '°'
    else
      return nil
    end
  end
  
  def air_pressure
    a_p = get_group(1, '3').to_s.strip
    if a_p.present?
      first = (a_p[1] == '0')? '1' : ''
      first + a_p[1,3] + ',' + a_p[4] + " мм.рт.ст."
    else
      return nil
    end
  end
  
  def air_pressure_sea_level
    a_p_s_l = get_group(1, '4').to_s.strip
    if a_p_s_l.present?
      first = (a_p_s_l[1] == '0')? '1' : ''
      first + a_p_s_l[1,3] + ',' + a_p_s_l[4] + " мм.рт.ст."
    else
      return nil
    end
  end
  
  def barometric_tendency
    bt_group = get_group(1, '5').to_s.strip
    
    if bt_group.present?
      flag = bt_group[1]
      value = bt_group[2,2] + "," + bt_group[4] + " мм.рт.ст."
      str = case flag
        when '0'
          " рост или без изменений "
        when '1'
          " рост "
        when '2'
          " рост "
        when '3'
          " рост "
        when '4'
          " без изменений "
        when '5'
          " падение или без изменений "
        when '6'
          " падение "
        when '7'
          " падение "
        when '8'
          " падение "
      end
      return str + value
    else
      return ''
    end
  end
  
  def precip_accum
    group6 = self["Телеграмма"][23,99].match(/ 6.... /)
    if group6.nil?
      "Осадков не было"
    else
      p_a = group6.to_s.strip[1,3].to_i
      case p_a
        when 0..988
          p_a.to_s + " мм."
        when 989
          p_a.to_s + " мм. и больше"
        when 990
          " следы осадков"
        when 991..999
          ((p_a - 990)*0.1).to_s + " мм."
      end
    end
  end
  
  private
    def get_group(num_section, flag)
      pos_group = self["Телеграмма"][23,99] =~ / #{flag}.... /
      if pos_group.present?
        s = self["Телеграмма"][23,99]
        if num_section == 1
          pos_333 = s =~ / 333 /
          if pos_333.present? 
            if (pos_group < pos_333)
              return s.match(/ #{flag}.... /)
            else
              return nil
            end
          end
          
          pos_555 = s =~ / 555 /
          if pos_555.present? 
            if (pos_group < pos_555)
              return s.match(/ #{flag}.... /)
            else
              return nil
            end
          end
          return s.match(/ #{flag}.... /)
        end
      else
        return nil
      end
    end
    
    def synoptic_telegramm_check
      if !term_valid?
        errors.add(:terms, "Неправильный срок")
      end
      if !group0_valid?
        errors.add(:group0, 'Неправилная различительная группа')
      end
    end

    # def open(url)
    #   Net::HTTP.get(URI.parse(url))
    # end
    
    # def self.find_in_ogimet(string) 
      # page_content = open('http://www.ogimet.com/cgi-bin/getsynop?begin=201704300000&state=Ukr').to_s
      # rows = page_content.split("=\n")
      # begin=YYYYMMDDHHmm  (mandatory)
      # end=YYYYMMDDHHmm  (default is current time)
      # lang=eng (english, optional)
      # header=yes (include a first line with the name of columns)
      # state=Begin_of_state_string 
      # block=First_digits_of_WMO_IND
      # ship=yes (to get ship reports for a time interval over the whole world)

      # http://www.ogimet.com/cgi-bin/getsynop?begin=201704280000&state=Ukr
    # end 
end