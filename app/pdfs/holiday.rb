require 'prawn'
class Holiday < Prawn::Document
  def initialize(bulletin)
		super(top_margin: 40)		
		@bulletin = bulletin
    font_families.update("OpenSans" => {
      :normal => Rails.root.join("./app/assets/fonts/OpenSans/OpenSans-Regular.ttf"),
      :italic => Rails.root.join("app/assets/fonts/OpenSans/OpenSans-Italic.ttf"),
      :bold => Rails.root.join("./app/assets/fonts/OpenSans/OpenSans-Bold.ttf"),
      :bold_italic => Rails.root.join("app/assets/fonts/OpenSans/OpenSans-BoldItalic.ttf")
    })
    y_pos = cursor
    image "./app/assets/images/logo.jpg", at: [0, y_pos], :scale => 0.25
    font "OpenSans", style: :bold
    bounding_box([50, y_pos], :width => 470) do
      text Bulletin::HEAD, align: :center
    end
    move_down 20
    font "OpenSans", style: :italic
    bounding_box([50, cursor], :width => 470) do
      text Bulletin::ADDRESS, align: :center, size: 10
    end
    move_down 20
    font "OpenSans", style: :bold
    bounding_box([50, cursor], :width => 470) do
      text "ГИДРОМЕТЕОРОЛОГИЧЕСКИЙ БЮЛЛЕТЕНЬ № #{@bulletin.curr_number} 
      #{@bulletin.report_date_as_str}", :color => "0000FF", align: :center 
    end
    move_down 20
    if @bulletin.storm.present?
      bounding_box([0, cursor], width: bounds.width) do
        text "ШТОРМОВОЕ ПРЕДУПРЕЖДЕНИЕ", align: :center, color: "ff0000"
        font "OpenSans"
        text @bulletin.storm
      end
    end
    move_down 10
    report_date = @bulletin.report_date.to_s
    report_date_next = (@bulletin.report_date + 1.day).to_s(:custom_datetime)
    font "OpenSans", style: :bold
    bounding_box([0, cursor], :width => bounds.width) do
      text "ПРОГНОЗ ПОГОДЫ
      на сутки с 21 часа #{report_date[8,2]} #{Bulletin::MONTH_NAME2[report_date[5,2].to_i]} до 21 часа #{report_date_next[8,2]} #{Bulletin::MONTH_NAME2[report_date_next[5,2].to_i]} #{report_date_next[0,4]} года", align: :center, :color => "0000FF"
    end
    font "OpenSans"
    move_down 10
    table weather_forecast, width: bounds.width, cell_style: { padding: 3, border_width: 0.3, border_color: "bbbbbb", :inline_format => true}
    move_down 10
    text "Дежурный синоптик #{@bulletin.duty_synoptic}", align: :right
    move_down 10
    report_date_next2 = (@bulletin.report_date + 2.day).to_s(:custom_datetime)
    report_date_next3 = (@bulletin.report_date + 3.day).to_s(:custom_datetime)
    font "./app/assets/fonts/DejaVu/DejaVuSansCondensed-Bold.ttf"
    text "Периодный прогноз погоды на #{report_date_next2[8,2]}-#{report_date_next3[8,2]} #{Bulletin::MONTH_NAME2[report_date_next3[5,2].to_i]} #{report_date_next3[0,4]} года
    в Донецкой Народной Республике", align: :center, color: "0000ff"
    font "OpenSans"
    text @bulletin.forecast_period
    move_down 10
    text "Синоптик #{@bulletin.synoptic1}", align: :right
    
    move_to 0, 15
    line_to 550, 15
    stroke_color '0000ff'
    stroke
  end
  def weather_forecast
		[ ["<b>В Донецкой Народной Республике</b>", "<b>В городе Донецке</b>"],
    [@bulletin.forecast_day, @bulletin.forecast_day_city]]
  end
end