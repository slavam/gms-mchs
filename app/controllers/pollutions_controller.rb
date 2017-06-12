require 'descriptive_statistics'
class PollutionsController < ApplicationController
  before_filter :required_params, :only => [:chem_forma1, :background_concentration]
  def index
    @pollutions = Pollution.paginate(page: params[:page]).order(:date, :idstation, :idsubstance).reverse_order
  end
  
  def chem_forma1
    @year = @pollution_date_end.year.to_s #'2005' 
    @month = month_mm
    @site_id =  5 # 20 for Gorlovka
    @matrix = get_matrix_data(@year, @month, @site_id)
  end
  
  def get_chem_forma1_data
    month = params[:month]
    year = params[:year]
    site_id = params[:site]
    # sites = Site.all.select(:idstation, :description).order(:idstation)
    matrix = get_matrix_data(year, month, site_id)
    render json: {year: year, month: month, matrix: matrix} # sites: sites, 
  end
  
  def get_chem_bc_data
    start_date = params[:start_date]
    end_date = params[:end_date]
    site_id = params[:site]
    substance_id = params[:substance]
    substance = Substance.find(substance_id).description
    concentrations = get_concentrations(start_date, end_date, site_id, substance_id)
    site = Site.find(site_id)
    site_description = site.description+'. Координаты: '+site.coordinate.to_s
    render json: {startDate: start_date, endDate: end_date, site_description: site_description, substance: substance, concentrations: concentrations}
  end
  
  def background_concentration
    @start_date = '2005-12-01'
    @end_date = @pollution_date_end.strftime('%F') #@start_date
    site_id = 5 # 20 for Gorlovka
    substance_id = 1
    
    @substance = Substance.find(substance_id).description
    substance_codes = Pollution.where("idsubstance < 100").select(:idsubstance).distinct.order(:idsubstance)
    s_c = []
    substance_codes.each do |s|
      s_c << s.idsubstance
    end
    @substances = Substance.find(s_c)

    site = Site.find(site_id)
    @site_description = site.description+'. Координаты: '+site.coordinate.to_s
    
    @concentrations = get_concentrations(@start_date, @end_date, site_id, substance_id)
    
  end
  
  private
    def transition_function(variance)
      # (1/(1+C244^2))*EXP(1.645*КОРЕНЬ(LN(1+C244^2)))
      s = 1.0 + variance*variance
      return ((1.0/s)*Math.exp(1.645*(Math.sqrt(Math.log(s))))).round(4)
    end
    
    def std_dev(arr)
      return 0 if arr.size < 2
      avg = arr.mean
      s = 0
      arr.each do |a| 
        # s += (a.to_f - avg)*(a.to_f - avg)
        s += (a.to_f - avg)**2
      end
      return Math.sqrt(s/(arr.size - 1).to_f).round(4)
    end
    
    def avg(arr)
      (arr.inject(:+).to_f / arr.size.to_f).round(4)
    end
    
    def get_concentrations(start_date, end_date, site_id, substance_id)
      my_query = "SELECT d.value, w_s.value speed, w_d.value direction, d.date from dimension d 
                  JOIN dimension w_s on d.date = w_s.date AND w_s.idsubstance = 102 AND w_s.value >= 0 AND w_s.idstation = #{site_id}
                  JOIN dimension w_d on w_d.date = w_s.date AND w_d.idsubstance = 101 AND w_d.idstation = #{site_id} 
                  WHERE d.idstation = #{site_id} AND d.idsubstance = #{substance_id} AND d.date >= '#{start_date}' AND d.date <= '#{end_date} 23:59:59';"
                  # WHERE d.idstation = #{site_id} AND d.idsubstance = #{substance_id} AND d.date BETWEEN '#{start_date}' AND '#{end_date}';"
      concentrations = Pollution.connection.select_all(my_query)
      if concentrations.count < 1
        my_query = "SELECT d.value, w_s.value speed, w_d.value direction, d.date from dimension d 
                  JOIN dimension w_s on d.date = w_s.date AND w_s.idsubstance = 102 AND w_s.value >= 0 AND w_s.idstation = 1
                  JOIN dimension w_d on w_d.date = w_s.date AND w_d.idsubstance = 101 AND w_d.idstation = 1
                  WHERE d.idstation = #{site_id} AND d.idsubstance = #{substance_id} AND d.date >= '#{start_date}' AND d.date <= '#{end_date} 23:59:59';"
        concentrations = Pollution.connection.select_all(my_query)
      end
      
      # !!!!!!!!!!! Gorlovka only
      # my_query = "SELECT d.value, w_s.value speed, w_d.value direction, d.date from dimension d 
      #             JOIN dimension w_s on d.date = w_s.date AND w_s.idsubstance = 102 AND w_s.value >= 0 AND w_s.idstation = 22
      #             JOIN dimension w_d on w_d.date = w_s.date AND w_d.idsubstance = 101 AND w_d.idstation = 22
      #             WHERE d.idstation = #{site_id} AND d.idsubstance = #{substance_id} AND d.date >= '#{start_date}' AND d.date <= '#{end_date} 23:59:59';"
      #   concentrations = Pollution.connection.select_all(my_query)
      conc_by_direction = {}
      conc_by_direction[:calm] = []
      conc_by_direction[:north] = []
      conc_by_direction[:east] = []
      conc_by_direction[:south] = []
      conc_by_direction[:west] = []
      conc_by_direction[:avg_calm] = 0
      conc_by_direction[:avg_north] = 0
      conc_by_direction[:avg_east] = 0
      conc_by_direction[:avg_south] = 0
      conc_by_direction[:avg_west] = 0
      conc_by_direction[:background_concentration_calm] = 0
      conc_by_direction[:background_concentration_north] = 0
      conc_by_direction[:background_concentration_east] = 0
      conc_by_direction[:background_concentration_south] = 0
      conc_by_direction[:background_concentration_west] = 0
      conc_by_direction[:standard_deviation_calm] = 0
      conc_by_direction[:standard_deviation_north] = 0
      conc_by_direction[:standard_deviation_east] = 0
      conc_by_direction[:standard_deviation_south] = 0
      conc_by_direction[:standard_deviation_west] = 0
      conc_by_direction[:variance_calm] = 0
      conc_by_direction[:variance_north] = 0
      conc_by_direction[:variance_east] = 0
      conc_by_direction[:variance_south] = 0
      conc_by_direction[:variance_west] = 0
      conc_by_direction[:transition_function_calm] = 0
      conc_by_direction[:transition_function_north] = 0
      conc_by_direction[:transition_function_east] = 0
      conc_by_direction[:transition_function_south] = 0
      conc_by_direction[:transition_function_west] = 0
      conc_by_direction[:concentration_calm] = 0
      conc_by_direction[:concentration_north] = 0
      conc_by_direction[:concentration_east] = 0
      conc_by_direction[:concentration_south] = 0
      conc_by_direction[:concentration_west] = 0
      conc_by_direction[:conc_bcg_avg5] = 0
      conc_by_direction[:conc_bcg_avg4] = 0
      conc_by_direction[:size] = 0
      conc_by_direction[:measurement_total] = 0
      conc_by_direction[:avg_total] = 0
      conc_by_direction[:avg_total_math] = 0
      conc_by_direction[:standard_deviation_total] = 0
      conc_by_direction[:standard_deviation_total_math] = 0
      conc_by_direction[:variance_total] = 0
      return conc_by_direction if concentrations.count < 1
      conc_by_direction[:measurement_total] = concentrations.count
      total = []
      concentrations.each do |c|
        total.push c['value'].to_f
        if c['speed'].to_i < 3
          conc_by_direction[:calm].push c['value'].to_f
        else
          direction = site_id.to_i < 15 ? c['direction'].to_i : c['direction'].to_i*10 # for Gorlovka
          case direction
            when 90-44..90+45
              conc_by_direction[:east].push c['value'].to_f
            when 180-44..180+45
              conc_by_direction[:south].push c['value'].to_f
            when 270-44..270+45
              conc_by_direction[:west].push c['value'].to_f
            else
              conc_by_direction[:north].push c['value'].to_f
          end
        end
      end
      conc_by_direction[:avg_total_math] = total.mean.round(4)
      conc_by_direction[:avg_total] = avg(total)
      conc_by_direction[:standard_deviation_total] = std_dev(total)
      conc_by_direction[:standard_deviation_total_math] = total.standard_deviation.round(4)
      conc_by_direction[:variance_total] = (conc_by_direction[:standard_deviation_total]/conc_by_direction[:avg_total]).round(4)
      # standard deviation
      # conc_by_direction[:standard_deviation_calm]  = conc_by_direction[:calm].standard_deviation.round(4)
      # conc_by_direction[:standard_deviation_north] = conc_by_direction[:north].standard_deviation.round(4)
      # conc_by_direction[:standard_deviation_east]  = conc_by_direction[:east].standard_deviation.round(4)
      # conc_by_direction[:standard_deviation_south] = conc_by_direction[:south].standard_deviation.round(4)
      # conc_by_direction[:standard_deviation_west]  = conc_by_direction[:west].standard_deviation.round(4)
      conc_by_direction[:standard_deviation_calm]  = std_dev(conc_by_direction[:calm]) # conc_by_direction[:calm].standard_deviation.round(4)
      conc_by_direction[:standard_deviation_north] = std_dev(conc_by_direction[:north]) # conc_by_direction[:north].standard_deviation.round(4)
      conc_by_direction[:standard_deviation_east]  = std_dev(conc_by_direction[:east]) # conc_by_direction[:east].standard_deviation.round(4)
      conc_by_direction[:standard_deviation_south] = std_dev(conc_by_direction[:south]) # conc_by_direction[:south].standard_deviation.round(4)
      conc_by_direction[:standard_deviation_west]  = std_dev(conc_by_direction[:west]) # conc_by_direction[:west].standard_deviation.round(4)
      # average
      conc_by_direction[:avg_calm]  = conc_by_direction[:calm].mean.round(4) if conc_by_direction[:calm].size > 0
      conc_by_direction[:avg_north] = conc_by_direction[:north].mean.round(4) if conc_by_direction[:north].size > 0
      conc_by_direction[:avg_east]  = conc_by_direction[:east].mean.round(4) if conc_by_direction[:east].size > 0
      conc_by_direction[:avg_south] = conc_by_direction[:south].mean.round(4) if conc_by_direction[:south].size > 0
      conc_by_direction[:avg_west]  = conc_by_direction[:west].mean.round(4) if conc_by_direction[:west].size > 0
      # max size from 5
      conc_by_direction[:size] = [conc_by_direction[:calm].size, 
                                   conc_by_direction[:north].size, 
                                   conc_by_direction[:east].size, 
                                   conc_by_direction[:south].size, 
                                   conc_by_direction[:west].size].max()
                       
      # коэффициент вариации                                   
      conc_by_direction[:variance_calm]  = (conc_by_direction[:standard_deviation_calm] /conc_by_direction[:avg_calm]).round(4) if conc_by_direction[:calm].size > 0
      conc_by_direction[:variance_north] = (conc_by_direction[:standard_deviation_north]/conc_by_direction[:avg_north]).round(4) if conc_by_direction[:north].size > 0
      conc_by_direction[:variance_east]  = (conc_by_direction[:standard_deviation_east] /conc_by_direction[:avg_east]).round(4) if conc_by_direction[:east].size > 0
      conc_by_direction[:variance_south] = (conc_by_direction[:standard_deviation_south]/conc_by_direction[:avg_south]).round(4) if conc_by_direction[:south].size > 0
      conc_by_direction[:variance_west]  = (conc_by_direction[:standard_deviation_west] /conc_by_direction[:avg_west]).round(4) if conc_by_direction[:west].size > 0
      # функция перехода
      conc_by_direction[:transition_function_calm]  = transition_function(conc_by_direction[:variance_calm])
      conc_by_direction[:transition_function_north] = transition_function(conc_by_direction[:variance_north])
      conc_by_direction[:transition_function_east]  = transition_function(conc_by_direction[:variance_east])
      conc_by_direction[:transition_function_south] = transition_function(conc_by_direction[:variance_south])
      conc_by_direction[:transition_function_west]  = transition_function(conc_by_direction[:variance_west])
      # концентрация с функцией перехода
      conc_by_direction[:concentration_calm] = (conc_by_direction[:transition_function_calm] * conc_by_direction[:avg_calm]).round(4) if conc_by_direction[:calm].size > 0
      conc_by_direction[:concentration_north] = (conc_by_direction[:transition_function_north] * conc_by_direction[:avg_north]).round(4) if conc_by_direction[:north].size > 0
      conc_by_direction[:concentration_east] = (conc_by_direction[:transition_function_east] * conc_by_direction[:avg_east]).round(4) if conc_by_direction[:east].size > 0
      conc_by_direction[:concentration_south] = (conc_by_direction[:transition_function_south] * conc_by_direction[:avg_south]).round(4) if conc_by_direction[:south].size > 0
      conc_by_direction[:concentration_west] = (conc_by_direction[:transition_function_west] * conc_by_direction[:avg_west]).round(4) if conc_by_direction[:west].size > 0
      
      conc_by_direction[:conc_bcg_avg5] = ((conc_by_direction[:concentration_calm]*conc_by_direction[:calm].size +
                                           conc_by_direction[:concentration_north]*conc_by_direction[:north].size +
                                           conc_by_direction[:concentration_east]*conc_by_direction[:east].size +
                                           conc_by_direction[:concentration_south]*conc_by_direction[:south].size +
                                           conc_by_direction[:concentration_west]*conc_by_direction[:west].size) / (conc_by_direction[:calm].size+conc_by_direction[:north].size+conc_by_direction[:east].size+conc_by_direction[:south].size+conc_by_direction[:west].size)).round(4)

      conc_by_direction[:conc_bcg_avg4] = ((conc_by_direction[:concentration_north]*conc_by_direction[:north].size +
                                           conc_by_direction[:concentration_east]*conc_by_direction[:east].size +
                                           conc_by_direction[:concentration_south]*conc_by_direction[:south].size +
                                           conc_by_direction[:concentration_west]*conc_by_direction[:west].size) / (conc_by_direction[:north].size+conc_by_direction[:east].size+conc_by_direction[:south].size+conc_by_direction[:west].size)).round(4)                                           

      conc_by_direction[:background_concentration_calm]  = conc_by_direction[:concentration_calm]
      conc_by_direction[:background_concentration_north] = conc_by_direction[:concentration_north]
      conc_by_direction[:background_concentration_east]  = conc_by_direction[:concentration_east]
      conc_by_direction[:background_concentration_south] = conc_by_direction[:concentration_south]
      conc_by_direction[:background_concentration_west]  = conc_by_direction[:concentration_west]
      c_b5 = [conc_by_direction[:concentration_calm], conc_by_direction[:concentration_north], conc_by_direction[:concentration_east], conc_by_direction[:concentration_south], conc_by_direction[:concentration_west]]
      if ((c_b5.max - conc_by_direction[:conc_bcg_avg5]) <= conc_by_direction[:conc_bcg_avg5]*0.25) and ((conc_by_direction[:conc_bcg_avg5] - c_b5.min) <= conc_by_direction[:conc_bcg_avg5]*0.25)
        conc_by_direction[:background_concentration_calm]  = conc_by_direction[:conc_bcg_avg5]
        conc_by_direction[:background_concentration_north] = conc_by_direction[:conc_bcg_avg5]
        conc_by_direction[:background_concentration_east]  = conc_by_direction[:conc_bcg_avg5]
        conc_by_direction[:background_concentration_south] = conc_by_direction[:conc_bcg_avg5]
        conc_by_direction[:background_concentration_west]  = conc_by_direction[:conc_bcg_avg5]
      else
        c_b4 = [conc_by_direction[:concentration_north], conc_by_direction[:concentration_east], conc_by_direction[:concentration_south], conc_by_direction[:concentration_west]]
        if ((c_b4.max - conc_by_direction[:conc_bcg_avg4]) <= conc_by_direction[:conc_bcg_avg4]*0.25) and ((conc_by_direction[:conc_bcg_avg4] - c_b4.min) <= conc_by_direction[:conc_bcg_avg4]*0.25)
          conc_by_direction[:background_concentration_calm]  = conc_by_direction[:concentration_calm]
          conc_by_direction[:background_concentration_north] = conc_by_direction[:conc_bcg_avg4]
          conc_by_direction[:background_concentration_east]  = conc_by_direction[:conc_bcg_avg4]
          conc_by_direction[:background_concentration_south] = conc_by_direction[:conc_bcg_avg4]
          conc_by_direction[:background_concentration_west]  = conc_by_direction[:conc_bcg_avg4]
        end
      end
      return conc_by_direction
    end
    
    def month_mm
      return (@pollution_date_end.month < 10 ? '0'+@pollution_date_end.month.to_s : @pollution_date_end.month.to_s)
    end
    
    def required_params
      @pollution_num = Pollution.count
      @pollution_date_start = Pollution.minimum("date")
      @pollution_date_end = Pollution.maximum("date")
      @sites = Site.all.select(:idstation, :description).order(:idstation)
      @site_num = Site.count
    end
    
    def get_matrix_data(year, month, site_id)
      matrix = {}
      site = Site.find(site_id)
      matrix[:site_description] = site.description+'. Координаты: '+site.coordinate.to_s
      matrix[:substance_num] = site.numsubstance
      
      pollutions_raw = Pollution.where("idstation = ? AND date like ?", site_id, year+'-'+month+'%').order(:date, :idsubstance)
      substance_codes = Pollution.where("idstation = ? AND date like ?", site_id, year+'-'+month+'%').select(:idsubstance).distinct.order(:idsubstance)
      substance_names = {}
      substance_codes.each do |s|
        substance_names[s.idsubstance] = s.substance.description
      end
      measure_num = Hash.new(0)
      max_values = Hash.new(0)
      avg_values = Hash.new(0)
      grouped_pollutions = pollutions_raw.group_by { |p| p.date }
      pollutions = {}
      grouped_pollutions.each do |k, g_p|
        a = {}
        substance_codes.each do |s|
          a[s.idsubstance] = ''
        end
        g_p.each do |p| 
          a[p.idsubstance] = p.value
          if p.value.present? 
            if p.idsubstance < 100
              measure_num[p.idsubstance] += 1 
              max_values[p.idsubstance] = p.value if p.value > max_values[p.idsubstance]
              avg_values[p.idsubstance] += p.value
            elsif p.idsubstance == 101 # направление ветра
              a[p.idsubstance] = a[p.idsubstance].to_i.to_s+'-'+wind_direct(a[p.idsubstance].to_i)
            end
          end
        end
        pollutions[k] = a.to_a
      end
      measure_num.each {|k, v| avg_values[k] = (avg_values[k] / v).round(3) if v > 0}
      
      matrix[:substance_names] = substance_names
      matrix[:pollutions] = pollutions
      matrix[:measure_num] = measure_num
      matrix[:max_values] = max_values
      matrix[:avg_values] = avg_values
      return matrix
    end
    def wind_direct(direct)
      case direct
      when 0..45, 360-45..360
        ret = 'N'
      when 46..90+45
        ret = 'E'
      when 136..180+45
        ret = 'S'
      else
        ret = 'W'
      end
      return ret
    end
end
