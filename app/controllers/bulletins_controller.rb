class BulletinsController < ApplicationController
  before_filter :find_bulletin, :only => [:holiday_show, :storm_show, :sea_show, :show, :destroy, :print_bulletin, :edit, :update]
  def index
    @bulletins = Bulletin.all.order(:created_at).reverse_order
  end

  def list
    @bulletin_type = params[:bulletin_type]
    @bulletins = Bulletin.where(bulletin_type: @bulletin_type).order(:created_at).reverse_order
  end
  
  def new_holiday_bulletin
    @bulletin = Bulletin.new
    @bulletin.report_date = Time.now.to_s(:custom_datetime)
    @bulletin.curr_number = Date.today.yday()
    @bulletin.bulletin_type = 'holiday'
  end

  def new_sea_bulletin
    @bulletin = Bulletin.new
    @bulletin.report_date = Time.now.to_s(:custom_datetime)
    @bulletin.curr_number = Date.today.yday()
    @bulletin.bulletin_type = 'sea'
  end

  def new_storm_bulletin
    @bulletin = Bulletin.new
    @bulletin.report_date = Time.now.to_s(:custom_datetime)
    @bulletin.bulletin_type = 'storm'
  end
  
  def new
    @bulletin = Bulletin.new
    @bulletin.report_date = Time.now.to_s(:custom_datetime)
    @bulletin.curr_number = Date.today.yday()
  end

  def create
    @bulletin = Bulletin.new(bulletin_params)
    # Rails.logger.debug("My object>>>>>>>>>>>>>>>: #{@bulletin.inspect}")
    if params[:val_1].present?
      @bulletin.meteo_data = ''
      (1..n).each do |i|
        @bulletin.meteo_data += params["val_#{i}"]+'; '
      end
    end
    if @bulletin.bulletin_type == 'daily'
      @bulletin.climate_data = params[:avg_day_temp] + '; ' + params[:max_temp] + '; '+ params[:max_temp_year] + '; ' + params[:min_temp] + '; '+ params[:min_temp_year] + '; '
    end
    if not @bulletin.save
      render :new
    else
      MeteoMailer.welcome_email(current_user).deliver_now
      redirect_to "/bulletins/list?bulletin_type="+@bulletin.bulletin_type 
    end
  end
  
  def edit
  end

  def update
    if params[:val_1].present?
      @bulletin.meteo_data = ''
      (1..n).each do |i|
        @bulletin.meteo_data += params["val_#{i}"].strip+'; '
      end
    end
    if @bulletin.bulletin_type == 'daily'
      @bulletin.climate_data = params[:avg_day_temp] + '; ' + params[:max_temp] + '; '+ params[:max_temp_year] + '; ' + params[:min_temp] + '; '+ params[:min_temp_year] + '; '
    end
    if not @bulletin.update_attributes bulletin_params
      render :action => :edit
    else
      redirect_to "/bulletins/list?bulletin_type="+@bulletin.bulletin_type
    end
  end

  def destroy
    bulletin_type = @bulletin.bulletin_type
    @bulletin.destroy
    redirect_to "/bulletins/list?bulletin_type="+bulletin_type
  end

  def show
  end
  
  def print_bulletin
  end

  def holiday_show
    respond_to do |format|
      format.html
      format.pdf do
        pdf = Holiday.new(@bulletin)
        send_data pdf.render, filename: "Bulletin_#{@bulletin.id}", type: "application/pdf", disposition: "inline", :force_download=>true, :page_size => "A4"
        
        filename = File.join(Rails.root, "app/assets/pdf_folder", "Bulletin_#{@bulletin.id}.pdf")
        pdf.render_file(filename)
        # unless File.exists?(filename)
        #   File.write(filename, render_to_string)
        # end
        send_file filename, :filename => "Bulletin_#{@bulletin.id}.pdf", :type => "application/pdf"
      end
    end
  end

  def sea_show
    respond_to do |format|
      format.html
      format.pdf do
        pdf = BulletinPdf.new(@bulletin)
        send_data pdf.render, filename: "Bulletin #{@bulletin.curr_number}", type: "application/pdf", disposition: "inline", :force_download=>true, :page_size => "A4"
      end
    end
  end

  def storm_show
    respond_to do |format|
      format.html
      format.pdf do
        pdf = Storm.new(@bulletin)
        send_data pdf.render, filename: "Bulletin #{@bulletin.curr_number}", type: "application/pdf", disposition: "inline", :force_download=>true, :page_size => "A4"
      end
    end
  end
  
  private
  
    def bulletin_params
      params.require(:bulletin).permit(:report_date, :curr_number, :duty_synoptic, :synoptic1, :synoptic2, :storm, :forecast_day, :forecast_day_city, :forecast_period, :forecast_advice, :forecast_orientation, :forecast_sea_day, :forecast_sea_period, :meteo_data, :agro_day_review, :climate_data, :summer, :bulletin_type, :storm_hour, :storm_minute)
    end
    
    def find_bulletin
      @bulletin = Bulletin.find(params[:id])
    end
    
    def n
      @bulletin.bulletin_type == 'sea' ? 13 : 36 
    end
end
