class PollutionsController < ApplicationController
  before_filter :required_params, :only => [:chem_forma1, :background_concentration]
  def index
    @pollutions = Pollution.paginate(page: params[:page]).order(:date, :idstation, :idsubstance).reverse_order
  end
  
  def chem_forma1
    @year = @pollution_date_end.year.to_s #'2005' 
    @month = month_mm
    @site_id = 5 
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
    month = params[:month]
    year = params[:year]
    site_id = params[:site]
    substance_id = params[:substance]
    substance = Substance.find(substance_id).description
    concentrations = get_concentrations(year, month, site_id, substance_id)
    site = Site.find(site_id)
    site_description = site.description+'. Координаты: '+site.coordinate.to_s
    render json: {year: year, month: month, site_description: site_description, substance: substance, concentrations: concentrations}
  end
  
  def background_concentration
    @year = @pollution_date_end.year.to_s
    @month = month_mm
    site_id = 5 
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
    
    @concentrations = get_concentrations(@year, @month, site_id, substance_id)
    
  end
  
  private
    def avg(arr)
      (arr.inject(:+).to_f / arr.size).round(3)
    end
    
    def get_concentrations(year, month, site_id, substance_id)
      yyyy_mm = year+'-'+month+'%'
      my_query = "SELECT d.value, w_s.value speed, w_d.value direction, d.date from dimension d 
                  JOIN dimension w_s on d.date = w_s.date AND w_s.idsubstance = 102 AND w_s.value >= 0 AND w_s.idstation = #{site_id}
                  JOIN dimension w_d on w_d.date = w_s.date AND w_d.idsubstance = 101 AND w_d.idstation = #{site_id} 
                  WHERE d.idstation = #{site_id} AND d.idsubstance = #{substance_id} AND d.date like '#{yyyy_mm}';"
      concentrations = Pollution.connection.select_all(my_query)
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
      conc_by_direction[:size] = 0
      concentrations.each do |c|
        if c['speed'].to_i < 3
          conc_by_direction[:calm].push c['value']
        else
          case +c['direction'].to_i
            when 90-45..90+45
              conc_by_direction[:east].push c['value']
            when 180-45..180+45
              conc_by_direction[:south].push c['value']
            when 270-45..270+45
              conc_by_direction[:west].push c['value']
            else
              conc_by_direction[:north].push c['value']
          end
        end
      end
      conc_by_direction[:avg_calm] = avg( conc_by_direction[:calm])
      conc_by_direction[:avg_north] = avg( conc_by_direction[:north])
      conc_by_direction[:avg_east] = avg( conc_by_direction[:east])
      conc_by_direction[:avg_south] = avg( conc_by_direction[:south])
      conc_by_direction[:avg_west] = avg( conc_by_direction[:west])
      conc_by_direction[:size] = [conc_by_direction[:calm].size, 
                                   conc_by_direction[:north].size, 
                                   conc_by_direction[:east].size, 
                                   conc_by_direction[:south].size, 
                                   conc_by_direction[:west].size].max()
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
