class SynopticsController < ApplicationController
  before_filter :find_synoptic, :only => [:show_by_date]
  Time::DATE_FORMATS[:custom_date_time] = "%Y.%m.%d %H:%M:%S"
  Time::DATE_FORMATS[:custom_datetime] = "%Y.%m.%d"
  def index
    @synoptics = Synoptic.all.limit(50).order("Дата").reverse_order
  end

  def create_synoptic_telegram
    telegram = Synoptic.new 
    telegram["Дата"] = Time.now.to_s(:custom_date_time)
    telegram["Срок"] = params[:t_term]
    telegram["Телеграмма"] = params[:t_text]
    if telegram.save
      render json: telegram
    else
      render json: telegram.errors, status: :unprocessable_entity
    end
  end
    
  def update_synoptic_telegram
    telegram = Synoptic.where("Дата = ?", params[:t_date])[0]
    sql = "update sinop set Телеграмма='#{params[:t_text]}' where Дата='#{params[:t_date]}';"
    connection = ActiveRecord::Base.connection
    connection.execute(sql)
    # telegram["Телеграмма"] = params[:t_text]
    # telegram.update_attribute("Телеграмма", params[:t_text])
    # if telegram.save
      render json: telegram
    # else
    #   render json: telegram.errors, status: :unprocessable_entity
    # end
  end
  
  def show_by_date
    # @synoptic = Synoptic.find_by_sql("SELECT * FROM sinop WHERE Дата = '2016.12.02 09:56:31';")[0]
    # @synoptic = Synoptic.where('Дата like "2015.02.26%"')
    # var_dump(@synoptic)
    # @synoptic = Synoptic.first
  end
  
  def heat_show
    curr_date = Time.now
    @hour = ((curr_date.hour / 3) * 3).to_s.rjust(2, '0')
    @calc_date = Time.now.to_s(:custom_datetime)
    @a = get_temperatures
  end
  
  def td_show
    @calc_date = params[:calc_date].present? ? params[:calc_date] : Time.now.to_s(:custom_datetime)
    @a = get_temperatures
  end
  
  def get_temps
    @calc_date = params[:calc_date].present? ? params[:calc_date] : Time.now.to_s(:custom_datetime)
    a = get_temperatures
    render json: a.to_json
  end
  
  def tcx1
    @month = Time.now.to_s(:custom_datetime)[5,2]
    @month_name = month_name(@month)
    @year = Time.now.year.to_s
    @num_days = Time.days_in_month(@month.to_i, @year.to_i)
    @avg_temps = get_tcx1_avg_temps(@month, @year)
    @max_temps = get_tcx1_max_temps(@num_days.to_s, @month, @year)
    @min_temps = get_tcx1_min_temps(@num_days.to_s, @month, @year)
    @max_wind_speed = get_tcx1_max_wind_speed(@month, @year)
    @min_soil_temps = get_tcx1_min_soil_temps(@month, @year)
    @min_humidity = get_min_relative_humidity(@month, @year)
    @rainfall = get_tcx1_rainfall(@month, @year)
    
    @data = {
      labels: (01..@num_days).to_a,
      datasets: [
        {
            label: 'Донецк',
            backgroundColor: "rgba(220,220,220,0.2)",
            borderColor: "rgba(22,22,22,1)",
            data: chart_data(@avg_temps, '34519', @num_days) 
        },
        {
            label: 'Дебальцево',
            backgroundColor: "rgba(220,220,220,0.2)",
            borderColor: "rgba(133,33,33,1)",
            data: chart_data(@avg_temps, '34524', @num_days) 
        },
        {
            label: 'Амвросиевка',
            backgroundColor: "rgba(220,220,220,0.2)",
            borderColor: "rgba(133,133,33,1)",
            data: chart_data(@avg_temps, '34622', @num_days) 
        }
    # ,
    # {
    #     label: "My Second dataset",
    #     backgroundColor: "rgba(151,187,205,0.2)",
    #     borderColor: "rgba(151,187,205,1)",
    #     data: [28, 48, 40, 19, 86, 27, 90]
    # }
      ]
    }
    @options = {
        responsive: true,
        maintainAspectRatio: false
    }
    # @options = { }
  end
  
  def get_tcx1_data
    month = params[:month]
    year = params[:year]
    num_days = Time.days_in_month(month.to_i, year.to_i)
    avg_temps = get_tcx1_avg_temps(month, year)
    max_temps = get_tcx1_max_temps(num_days.to_s, month, year)
    min_temps = get_tcx1_min_temps(num_days.to_s, month, year)
    max_wind_speed = get_tcx1_max_wind_speed(month, year)
    min_soil_temps = get_tcx1_min_soil_temps(month, year)
    min_humidity = get_min_relative_humidity(month, year)
    rainfall = get_tcx1_rainfall(month, year)
    render json: {avgTemps: avg_temps, monthName: month_name(month), year: year, numDays: num_days, maxTemps: max_temps, minTemps: min_temps, maxWindSpeed: max_wind_speed, minSoilTemps: min_soil_temps, minHumidity: min_humidity, rainfall: rainfall}
  end
  
  private
    def find_synoptic
      @synoptic = Synoptic.where("Дата = ?", params["Дата"])[0]
    end
    
    def chart_data (src, station, num_days)
      c_d = []
      (1..num_days).each do |d|
        d = '0'+d.to_s if d < 10
        c_d << src[station.to_s+'-'+d.to_s]
      end
      c_d
    end
    
    def get_tcx1_avg_temps(month, year)
      agro_data = Agro.where("Дата like '#{year}.#{month}%' and Телеграмма like 'ЩЭАГЯ%34% 333 90%'").order("Дата")
      avg_temps = Hash.new(nil)
      agro_data.each { |ad|
        station = ad["Телеграмма"].match(/ 34... /).to_s.strip
        day = ad["Дата"][8,2].to_s.strip
        val = ad["Телеграмма"].match(/ 333 90... 1..../).to_s.strip[11,4]
        if val.present?
          sign = val[0] == '0' ? '' : '-'
          avg_temps[station+'-'+day] = sign+val[1,2].to_s+'.'+val[3].to_s
        end
      }
      avg_temps
    end

    def get_tcx1_max_temps(last_day, month, year)
      max_data = Synoptic.where("Дата between '#{year}.#{month}.01 00:00:00' and '#{year}.#{month}.#{last_day} 23:59:59' and Срок = '18' and Телеграмма like '% 333 1%'")
      max_temps = Hash.new(nil)
      max_data.each {|md|
        station = md["Телеграмма"].match(/ 34... /).to_s.strip
        day = md["Дата"][8,2].to_s.strip
        val = md["Телеграмма"].match(/ 333 1..../).to_s.strip[5,4]
        if val.present?
          sign = val[0] == '0' ? '' : '-'
          max_temps[station+'-'+day] = sign+val[1,2].to_s+'.'+val[3].to_s
        end
      }
      max_temps
    end
    
    def get_tcx1_min_soil_temps(month, year)
      agro_data = Agro.where("Дата like '#{year}.#{month}%' and Телеграмма like 'ЩЭАГЯ 34% 333 90___ 1____ 3____ 4%'").order("Дата")
      min_soil = Hash.new(nil)
      agro_data.each { |ad|
        station = ad["Телеграмма"].match(/ 34... /).to_s.strip
        day = ad["Дата"][8,2].to_s.strip
        val = ad["Телеграмма"].match(/ 333 90... 1.... 3.... 4.../).to_s.strip[23,3]
        if val.present?
          sign = val[0] == '0' ? '' : '-'
          min_soil[station+'-'+day] = sign+val[1,2].to_s
        end
      }
      min_soil
    end
    
    def get_min_relative_humidity(month, year)
      agro_data = Agro.where("Дата like '#{year}.#{month}%' and Телеграмма like 'ЩЭАГЯ 34% 91___ 3%'").order("Дата")
      min_humidity = Hash.new(nil)
      agro_data.each { |ad|
        station = ad["Телеграмма"].match(/ 34... /).to_s.strip
        day = ad["Дата"][8,2].to_s.strip
        pos_91 = ad["Телеграмма"] =~ / 91... /
        if pos_91.present?
          group91 = ad["Телеграмма"][pos_91, 99]
          val = group91.match(/ 3..../).to_s.strip[3,2]
          if val.present?
            min_humidity[station+'-'+day] = val.to_s
          end
        end
      }
      min_humidity
    end
  
    def get_tcx1_min_temps(last_day, month, year)
      min_data = Synoptic.where("Дата between '#{year}.#{month}.01 00:00:00' and '#{year}.#{month}.#{last_day} 23:59:59' and Срок = '06' and Телеграмма like '% 333 2%'")
      min_temps = Hash.new(nil)
      min_data.each {|md|
        station = md["Телеграмма"].match(/ 34... /).to_s.strip
        day = md["Дата"][8,2].to_s.strip
        val = md["Телеграмма"].match(/ 333 2..../).to_s.strip[5,4]
        if val.present?
          sign = val[0] == '0' ? '' : '-'
          min_temps[station+'-'+day] = sign+val[1,2].to_s+'.'+val[3].to_s
        end
      }
      min_temps
    end

    def get_tcx1_max_wind_speed(month, year)
      agro_data = Agro.where("Дата like '#{year}.#{month}%' and Телеграмма like 'ЩЭАГЯ 34% 7%'").order("Дата")
      max_wind = Hash.new(nil)
      agro_data.each { |ad|
        station = ad["Телеграмма"].match(/ 34... /).to_s.strip
        day = ad["Дата"][8,2].to_s.strip
        val = ad["Телеграмма"].match(/ 7..../).to_s.strip[1,2]
        if val.present?
          max_wind[station+'-'+day] = val.to_s
        end
      }
      max_wind
    end

    def get_tcx1_rainfall(month, year)
      syn_data = Synoptic.where("Дата like '#{year}.#{month}%' and (Срок = '06' or Срок = '18') and Телеграмма like 'ЩЭ___ 34___ _____ _____% 6____ %'")
      rainfall = Hash.new(0.0)
      syn_data.each {|sd|
        pos_555 = sd =~ / 555 /
        pos_group6 = sd =~ / 6.... /
        if pos_555.present? 
          if (pos_group6 > pos_555)
            next # пропустить шестую группу из раздела 555
          end
        end
        station = sd["Телеграмма"].match(/ 34... /).to_s.strip
        day = sd["Дата"][8,2].to_s.strip
        code = sd["Телеграмма"].match(/ 6..../).to_s.strip[1,3].to_i
        val = 0.0
        case code
          when 0..989
            val = code
          when 991..999
            val = ((code - 990).to_d)*0.1
        end
        rainfall[station+'-'+day] += val.round(2)
      }
      rainfall
    end
    
    def get_temperatures
      heat_data = Synoptic.where("Дата like ? and Срок BETWEEN '00' and '21' ", @calc_date+'%').order("Срок")
      a = Hash.new(nil)
      heat_data.each {|hd|
        station_code = hd["Телеграмма"].split(' ')[1]
        # a[[station_code, hd["Срок"]]] = hd.temp_to_s
        a[station_code+'-'+hd["Срок"]] = hd.temp_to_s
      }
      a
    end
end