require 'RMagick'
class BulletinsController < ApplicationController
  before_filter :find_bulletin, :only => [:bulletin_show, :show, :destroy, :print_bulletin, :edit, :update]
  # after_filter :pdf_png_delete, :only => [:holiday_show]
  # def index
  #   @bulletins = Bulletin.all.order(:created_at).reverse_order
  # end

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
    @bulletin.curr_number = Date.today.yday()
    @bulletin.bulletin_type = params[:bulletin_type]
  end
  
  def new_radiation_bulletin
    @bulletin = Bulletin.new
    @bulletin.report_date = Time.now.to_s(:custom_datetime)
    @bulletin.curr_number = Date.today.yday()
    @bulletin.bulletin_type = 'radiation'
  end

  def new_tv_bulletin
    @bulletin = Bulletin.new
    @bulletin.report_date = Time.now.to_s(:custom_datetime)
    @bulletin.bulletin_type = 'tv'
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
    @bulletin.curr_number ||= Date.today.yday().to_s+'-tv' if @bulletin.bulletin_type == 'tv'
    if not @bulletin.save
      render :new
    else
      # MeteoMailer.welcome_email(current_user).deliver_now
      # redirect_to "/bulletins/list?bulletin_type="+@bulletin.bulletin_type
      redirect_to "/bulletins/#{@bulletin.id}/bulletin_show"
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
      redirect_to "/bulletins/#{@bulletin.id}/bulletin_show"
    end
  end

  def destroy
    bulletin_type = @bulletin.bulletin_type
    @bulletin.destroy
    redirect_to "/bulletins/list?bulletin_type="+bulletin_type
  end
  
  # def pdf_png_delete
  #   filename = File.join(Rails.root, "app/assets/pdf_folder", @bulletin.pdf_filename)
  #   File.delete(filename) if File.exist?(filename)
  #   filename = File.join(Rails.root, "app/assets/pdf_folder", @bulletin.png_filename)
  #   File.delete(filename) if File.exist?(filename)
  # end

  def show
  end
  
  def print_bulletin
  end

  def pdf_2_png
    pdf = Magick::ImageList.new("app/assets/pdf_folder/#{@bulletin.pdf_filename(current_user.id)}")
    pdf.write("app/assets/pdf_folder/#{@bulletin.png_filename(current_user.id)}")
    return true
  end
  
  def pdf_2_png_2
    pdf = MiniMagick::Image.open("app/assets/pdf_folder/#{@bulletin.pdf_filename(current_user.id)}")
    pdf.resize "200x200"
    pdf.format "png"
    pdf.write("app/assets/pdf_folder/#{@bulletin.png_filename(current_user.id)}")
    return true
  end
  
  def save_as_pdf(pdf)
    # send_data pdf.render, filename: @bulletin.pdf_filename, type: "application/pdf", disposition: "inline", :force_download=>true, :page_size => "A4"
    filename = File.join(Rails.root, "app/assets/pdf_folder", @bulletin.pdf_filename(current_user.id))
    pdf.render_file(filename)
  end

  def bulletin_show
    respond_to do |format|
      case @bulletin.bulletin_type
        when 'daily'
          pdf = Daily.new(@bulletin)
          @png_filename_page1 = @bulletin.png_page_filename(current_user.id, 0)
          @png_filename_page2 = @bulletin.png_page_filename(current_user.id, 1)
        when 'sea'
          pdf = Sea.new(@bulletin)
          @png_filename_page1 = @bulletin.png_page_filename(current_user.id, 0)
          @png_filename_page2 = @bulletin.png_page_filename(current_user.id, 1)
        when 'holiday'
          pdf = Holiday.new(@bulletin)
          @png_filename = @bulletin.png_filename(current_user.id)
        when 'storm', 'sea_storm'
          pdf = Storm.new(@bulletin)
          @png_filename = @bulletin.png_filename(current_user.id)
        when 'radiation'
          pdf = Radiation.new(@bulletin)
          @png_filename = @bulletin.png_filename(current_user.id)
        when 'tv'
          pdf = Tv.new(@bulletin)
          @png_filename = @bulletin.png_filename(current_user.id)
      end
      format.html do
        save_as_pdf(pdf)
        pdf_2_png
      end
      format.pdf do
        send_data pdf.render, filename: @bulletin.pdf_filename(current_user.id), type: "application/pdf", disposition: "inline", :force_download=>true, :page_size => "A4"
      end
    end
  end
  
  # def daily_show
  #   respond_to do |format|
  #     pdf = Daily.new(@bulletin)
  #     format.html do
  #       save_as_pdf(pdf)
  #       pdf_2_png
  #       @png_filename_page1 = @bulletin.png_page_filename(current_user.id, 0)
  #       @png_filename_page2 = @bulletin.png_page_filename(current_user.id, 1)
  #     end
  #     format.pdf do
  #       send_data pdf.render, filename: @bulletin.pdf_filename(current_user.id), type: "application/pdf", disposition: "inline", :force_download=>true, :page_size => "A4"
  #     end
  #   end
  # end

  # def holiday_show
  #   respond_to do |format|
  #     pdf = Holiday.new(@bulletin)
  #     format.html do
  #       save_as_pdf(pdf)
  #       pdf_2_png
  #       @png_filename = @bulletin.png_filename(current_user.id)
  #       # filename = File.join(Rails.root, "app/assets/pdf_folder", @bulletin.png_filename)
  #       # pdf = MiniMagick::Image.open("app/assets/pdf_folder/#{@bulletin.pdf_filename}")
  #       # pdf.format "png"
  #       # @img = Magick::Image.new(280, 100) { self.background_color = 'blue' }
  #       # img_blob = pdf.to_blob
  #       # send_data img_blob, filename: filename, disposition: 'inline', type: 'image/png'
        
  #       # File.open(filename, 'r') do |f|
  #         # send_data @img_blob, filename: filename, disposition: 'inline', type: 'image/png'
  #         # send_data f.read
  #       # end
  #       # File.delete(filename)
  #     end
  #     format.pdf do
  #       send_data pdf.render, filename: @bulletin.pdf_filename(current_user.id), type: "application/pdf", disposition: "inline", :force_download=>true, :page_size => "A4"
  #     end
  #   end
  # end
  
  # def sea_show
  #   respond_to do |format|
  #     pdf = Sea.new(@bulletin)
  #     format.html do
  #       save_as_pdf(pdf)
  #       pdf_2_png
  #       @png_filename_page1 = @bulletin.png_page_filename(current_user.id, 0)
  #       @png_filename_page2 = @bulletin.png_page_filename(current_user.id, 1)
  #     end
  #     format.pdf do
  #       send_data pdf.render, filename: @bulletin.pdf_filename(current_user.id), type: "application/pdf", disposition: "inline", :force_download=>true, :page_size => "A4"
        
  #       # send_data pdf.render, filename: "Bulletin #{@bulletin.curr_number}", type: "application/pdf", disposition: "inline", :force_download=>true, :page_size => "A4"
  #     end
  #   end
  # end

  # def storm_show
  #   respond_to do |format|
  #     pdf = Storm.new(@bulletin)
  #     format.html do
  #       save_as_pdf(pdf)
  #       pdf_2_png
  #       @png_filename = @bulletin.png_filename(current_user.id)
  #     end
  #     format.pdf do
  #       send_data pdf.render, filename: @bulletin.pdf_filename(current_user.id), type: "application/pdf", disposition: "inline", :force_download=>true, :page_size => "A4"
  #     end
  #   end
  # end
  
  private
  
    def bulletin_params
      params.require(:bulletin).permit(:report_date, :curr_number, :duty_synoptic, :synoptic1, :synoptic2, :storm, :forecast_day, :forecast_day_city, :forecast_period, :forecast_advice, :forecast_orientation, :forecast_sea_day, :forecast_sea_period, :meteo_data, :agro_day_review, :climate_data, :summer, :bulletin_type, :storm_hour, :storm_minute, :picture)
    end
    
    def find_bulletin
      @bulletin = Bulletin.find(params[:id])
    end
    
    def n
      case @bulletin.bulletin_type
        when 'sea'
          13
        when 'radiation'
          4
        when 'tv'
          38
        else
          36        
      end
    end
end
