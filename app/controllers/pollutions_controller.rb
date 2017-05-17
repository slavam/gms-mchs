class PollutionsController < ApplicationController
  def index
    @pollutions = Pollution.paginate(page: params[:page]).order(:date, :idstation, :idsubstance).reverse_order
  end
  
  def chem_forma1
    @pollution_all = Pollution.count
    @pollution_date_start = Pollution.minimum("date")
    @pollution_date_end = Pollution.maximum("date")
    @year = '2005' #params[:year]
    @month = '12' #params[:month]
    @station = 5 #params[:station]
    @pollutions = {}
    if @year.present? and @month.present? and @station.present?
      @site_all = Site.count
      site = Site.find(@station)
      @site_description = site.description+'. Координаты: '+site.coordinate.to_s
      @substantion_num = site.numsubstance
      pollutions = Pollution.where("idstation = ? AND date like ?", @station, @year+'-'+@month+'%').order(:date, :idsubstance)
      substance_codes = Pollution.where("idstation = ? AND date like ?", @station, @year+'-'+@month+'%').select(:idsubstance).distinct.order(:idsubstance)
      @subst_names = {}
      substance_codes.each do |s|
        @subst_names[s.idsubstance] = s.substance.description
      end
      @measure_num = Hash.new(0)
      @max_values = Hash.new(0)
      @avg_values = Hash.new(0)
      grouped_pollutions = pollutions.group_by { |p| p.date }
      grouped_pollutions.each do |k, g_p|
        a = {}
        substance_codes.each do |s|
          a[s.idsubstance] = ''
        end
        g_p.each do |p| 
          a[p.idsubstance] = p.value
          if p.value.present? and p.idsubstance < 100
            @measure_num[p.idsubstance] += 1 
            @max_values[p.idsubstance] = p.value if p.value > @max_values[p.idsubstance]
            @avg_values[p.idsubstance] += p.value
          end
        end
        @pollutions[k] = a.to_a
      end
      @measure_num.each {|k, v| @avg_values[k] = (@avg_values[k] / v).round(3) if v > 0}
    end
  end
end
