class SynopticsController < ApplicationController
  before_filter :find_synoptic, :only => [:show_by_date]
  Time::DATE_FORMATS[:custom_datetime] = "%Y.%m.%d"
  def index
    @synoptics = Synoptic.all.limit(50).order("Дата").reverse_order
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
    @calc_date = (Time.now - 30.days).to_s(:custom_datetime)
    @a = get_temperatures
  end
  
  def td_show
    @calc_date = params[:calc_date].present? ? params[:calc_date] : (Time.now - 30.days).to_s(:custom_datetime)
    @a = get_temperatures
  end
  
  def get_temps
    @calc_date = params[:calc_date].present? ? params[:calc_date] : (Time.now - 30.days).to_s(:custom_datetime)
    a = get_temperatures
    render json: a.to_json
  end
  
  def tcx1
    @month = '11'
    @month_name = month_name(@month)
    @year = Time.now.year.to_s
    @num_days = Time.days_in_month(@month.to_i, @year)
    @avg_temps = get_tcx1_avg_temps(@month, @year)
    @max_temps = get_tcx1_max_temps(@num_days.to_s, @month, @year)
  end
  
  def get_tcx1_data
    month = params[:month]
    year = params[:year]
    num_days = Time.days_in_month(month.to_i, year)
    avg_temps = get_tcx1_avg_temps(month, year)
    max_temps = get_tcx1_max_temps(num_days.to_s, month, year)
    render json: {avgTemps: avg_temps, monthName: month_name(month), year: year, numDays: num_days, maxTemps: max_temps}
  end
  
  private
    def find_synoptic
      @synoptic = Synoptic.where("Дата = ?", params["Дата"])[0]
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
    # select * from agro where Телеграмма like 'ЩЭАГЯ%34514% 333 90%' order by Дата desc limit 30;
end