class PollutionsController < ApplicationController
  before_filter :required_params, :only => [:chem_forma1]
  def index
    @pollutions = Pollution.paginate(page: params[:page]).order(:date, :idstation, :idsubstance).reverse_order
  end
  
  def chem_forma1
    @year = '2005' 
    @month = '12' 
    @site_id = 5 
    @matrix = get_matrix_data(@year, @month, @site_id)
    # @pollutions = {}
    # if @year.present? and @month.present? and @site.present?
    #   site = Site.find(@site)
    #   @site_description = site.description+'. Координаты: '+site.coordinate.to_s
    #   @substantion_num = site.numsubstance
      
    #   pollutions = Pollution.where("idstation = ? AND date like ?", @station, @year+'-'+@month+'%').order(:date, :idsubstance)
    #   substance_codes = Pollution.where("idstation = ? AND date like ?", @station, @year+'-'+@month+'%').select(:idsubstance).distinct.order(:idsubstance)
    #   @substance_names = {}
    #   substance_codes.each do |s|
    #     @substance_names[s.idsubstance] = s.substance.description
    #   end
    #   @measure_num = Hash.new(0)
    #   @max_values = Hash.new(0)
    #   @avg_values = Hash.new(0)
    #   grouped_pollutions = pollutions.group_by { |p| p.date }
    #   grouped_pollutions.each do |k, g_p|
    #     a = {}
    #     substance_codes.each do |s|
    #       a[s.idsubstance] = ''
    #     end
    #     g_p.each do |p| 
    #       a[p.idsubstance] = p.value
    #       if p.value.present? and p.idsubstance < 100
    #         @measure_num[p.idsubstance] += 1 
    #         @max_values[p.idsubstance] = p.value if p.value > @max_values[p.idsubstance]
    #         @avg_values[p.idsubstance] += p.value
    #       end
    #     end
    #     @pollutions[k] = a.to_a
    #   end
    #   @measure_num.each {|k, v| @avg_values[k] = (@avg_values[k] / v).round(3) if v > 0}
    # end
  end
  
  def get_chem_forma1_data
    month = params[:month]
    year = params[:year]
    site_id = params[:site]
    sites = Site.all.select(:idstation, :description).order(:idstation)
    matrix = get_matrix_data(year, month, site_id)
    render json: {year: year, month: month, sites: sites, matrix: matrix}
  end
  
  private
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
          if p.value.present? and p.idsubstance < 100
            measure_num[p.idsubstance] += 1 
            max_values[p.idsubstance] = p.value if p.value > max_values[p.idsubstance]
            avg_values[p.idsubstance] += p.value
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
end
