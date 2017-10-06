require 'prawn'
class Sea < Prawn::Document
  MONTH_NAME2 = %w{nil января февраля марта апреля мая июня июля августа сентября октября ноября декабря}
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
    font "./app/assets/fonts/OpenSans/OpenSans-Bold.ttf"
    bounding_box([50, y_pos], :width => 470) do
        text Bulletin::HEAD, align: :center
    end
    move_down 20
    font "./app/assets/fonts/OpenSans/OpenSans-Regular.ttf"
    bounding_box([50, cursor], :width => 470) do
        text Bulletin::ADDRESS, align: :center, size: 10
    end
    report_date = @bulletin.report_date.to_s(:custom_datetime)
    font "./app/assets/fonts/DejaVu/DejaVuSansCondensed-Bold.ttf"
    move_down 20
    bounding_box([50, cursor], :width => 470) do
      text "МОРСКОЙ ГИДРОМЕТЕОРОЛОГИЧЕСКИЙ БЮЛЛЕТЕНЬ № #{@bulletin.curr_number} 
      #{@bulletin.report_date_as_str}", :color => "0000FF", align: :center 
    end
    move_down 20
    if @bulletin.storm.present?
      bounding_box([0, cursor], width: bounds.width) do
        text "ШТОРМОВОЕ ПРЕДУПРЕЖДЕНИЕ", align: :center, color: "ff0000"
        font "./app/assets/fonts/OpenSans/OpenSans-Light.ttf"
        text @bulletin.storm
      end
    end
    move_down 10
    report_date_next = (@bulletin.report_date + 1.day).to_s(:custom_datetime)
    font "./app/assets/fonts/DejaVu/DejaVuSansCondensed-Bold.ttf"
    bounding_box([0, cursor], :width => bounds.width) do
      text "ПРОГНОЗ ПОГОДЫ
      на сутки с 21 часа #{report_date[8,2]} #{MONTH_NAME2[report_date[5,2].to_i]} до 21 часа #{report_date_next[8,2]} #{MONTH_NAME2[report_date_next[5,2].to_i]} #{report_date_next[0,4]} года", align: :center, :color => "0000FF"
    end
    font "OpenSans"
    move_down 10
    table weather_forecast, width: bounds.width, cell_style: { padding: 3, border_width: 0.3, border_color: "bbbbbb", :inline_format => true}
    move_down 10
    report_date_next2 = (@bulletin.report_date + 2.day).to_s(:custom_datetime)
    report_date_next3 = (@bulletin.report_date + 3.day).to_s(:custom_datetime)
    font "./app/assets/fonts/DejaVu/DejaVuSansCondensed-Bold.ttf"
    text "Периодный прогноз погоды на #{report_date_next2[8,2]}-#{report_date_next3[8,2]} #{MONTH_NAME2[report_date_next3[5,2].to_i]} #{report_date_next3[0,4]} года
    По акватории Азовского моря (на участке с. Безыменное – пгт. Седово)", align: :center, color: "0000ff"
    font "OpenSans"
    text @bulletin.forecast_period
    move_down 10
    text "Синоптик #{@bulletin.synoptic1}", align: :right
    
    start_new_page layout: :landscape
    font "./app/assets/fonts/DejaVu/DejaVuSansCondensed-Bold.ttf"
    text "Приложение к Морскому Гидрометеорологическому Бюллетеню
    от #{@bulletin.report_date_as_str} № #{@bulletin.curr_number}", align: :center, :color => "0000FF"
    text "МЕТЕОРОЛОГИЧЕСКИЕ ДАННЫЕ И СВЕДЕНИЯ О СОСТОЯНИИ МОРЯ", align: :center, :color => "0000FF"
    move_down 10
    font "OpenSans"
    table meteo_data, width: bounds.width, cell_style: {padding: 3, border_width: 0.3, border_color: "bbbbbb", :inline_format => true, size: 9} do |t|
      t.cells.padding = [1, 1]
      t.cells.align = :center
      t.row(0).columns(0).width = 90
      t.row(1).columns(7).width = 90
      t.row(1).columns(1..6).rotate = 90
      t.row(1).columns(8..13).rotate = 90
      t.row(1).columns(1..13).height = 100
      t.row(0).column(0).valign = :center
      t.row(1).column(7).valign = :center
      t.row(5).align = :left
      t.row(1).column(1).width = 40
      t.row(1).column(2).width = 40
      t.row(1).column(3).width = 40
    end
    move_down 10
    table signatures, width: bounds.width, :column_widths => [300, 100], cell_style: {:overflow => :shrink_to_fit, :font => 'OpenSans', :inline_format => true } do |t|
      t.cells.border_width = 0
    end
	end

	def weather_forecast
		[ ["<b>По акватории Азовского моря (на участке с. Безыменное – пгт. Седово)</b>", "<b>В пгт. Седово</b>"],
      [@bulletin.forecast_day, @bulletin.forecast_day_city]]
	end
	def meteo_data
    m_d = []
    m_d = @bulletin.meteo_data.split(";") if @bulletin.meteo_data.present?
    report_date_prev = (@bulletin.report_date - 1.day).to_s(:custom_datetime)
	  [
	    [{:content => "Название
	    метеостанции", :rowspan => 2},{:content => "за период с 9.00 часов #{report_date_prev[8,2]} #{MONTH_NAME2[report_date_prev[5,2].to_i]} до 9.00 часов #{@bulletin.report_date_as_str}",
	    :colspan => 7},{:content => "в срок 9.00 часов #{@bulletin.report_date_as_str}", :colspan => 6}],
	    [
	    "<color rgb='ff0000'>Максимальная 
	    температура воздуха
	    вчера днем</color>", 
	    "<color rgb='0000ff'>Минимальная 
	    температура воздуха
	    сегодня ночью</color>", 
	    "Температура воздуха
	    в 9.00 часов сегодня", 
	    "Количество осадков 
	    за сутки (мм)", "Направление ветра", "Максимальная скорость ветра (м/с)", "Явления погоды", 
	    "Уровень моря
	    над '0' поста (см)", 
	    "Повышение (+) 
	    понижение (-) 
	    уровня моря 
	    за сутки (см)", "Температура воды", "Направление волн", "Высота волн (дм)", 
	    "Видимость"],
	    ['Седово', m_d[0], m_d[1], m_d[2], m_d[3], m_d[4], m_d[5], m_d[6], m_d[7], m_d[8], m_d[9], m_d[10], m_d[11], m_d[12]],
	    [{:content => "за период с 9.00 часов #{report_date_prev[8,2]} #{MONTH_NAME2[report_date_prev[5,2].to_i]} до 9.00 часов #{@bulletin.report_date_as_str}", :colspan => 14}],
	    [{:content => "<color rgb='0000ff'>ОБЗОР ПОГОДЫ</color>", :colspan => 8},{:content => "<color rgb='0000ff'>ОБЗОР СОСТОЯНИЯ АЗОВСКОГО МОРЯ</color>", :colspan => 6}],
	    [{content: @bulletin.forecast_sea_day, colspan: 8},{content: @bulletin.forecast_sea_period, colspan: 6}]
    ]
	end
	def signatures
    image1 = "./app/assets/images/head_of_dep.png"
    image2 = "./app/assets/images/chief.png"
    [ ["Ответственный за выпуск:","",""],
      ["Начальник отдела гидрометеорологического обеспечения и обслуживания", {image: image1, scale: 0.6}, "Л.Н. Бойко"],
      ["<b>Начальник</b>", {image: image2, scale: 0.6},"<b>М.Б. Лукьяненко</b>"]
    ]
	end
end