prawn_document do |pdf|
# pdf.stroke_bounds
  pdf.font "./app/assets/fonts/DejaVu/DejaVuSansCondensed-Bold.ttf"
  pdf.font "./app/assets/fonts/OpenSans/OpenSans-Light.ttf"
  y_pos = pdf.cursor
  pdf.image "./app/assets/images/logo.jpg", at: [0, pdf.cursor], :scale => 0.25
  pdf.bounding_box([50, y_pos], :width => 470, :height => 100) do
    # pdf.stroke_bounds
    pdf.text "МЧС ДНР", align: :center
    pdf.text "ГИДРОМЕТЕОРОЛОГИЧЕСКАЯ СЛУЖБА", align: :center
    pdf.text "МИНИСТЕРСТВА ПО ДЕЛАМ ГРАЖДАНСКОЙ ОБОРОНЫ, ЧРЕЗВЫЧАЙНЫМ", align: :center
    pdf.text "СИТУАЦИЯМ И ЛИКВИДАЦИИ ПОСЛЕДСТВИЙ СТИХИЙНЫХ БЕДСТВИЙ", align: :center
    pdf.text "ДОНЕЦКОЙ НАРОДНОЙ РЕСПУБЛИКИ", align: :center
    pdf.text "(ГМС МЧС ДНР)", align: :center
  end
  pdf.bounding_box([50, pdf.cursor-10], :width => 470, :height => 30) do
    # pdf.stroke_bounds
    pdf.text "ул. Любавина, 2, г. Донецк, 83015", align: :center, size: 10
    pdf.text "телефон: (062) 304-82-22, телефон/факс: (062) 304-99-25, e-mail: gidromet@mail.dnmchs.ru", align: :center, size: 10
  end
  report_date = @bulletin.report_date.to_s(:custom_datetime)
  pdf.font "./app/assets/fonts/DejaVu/DejaVuSansCondensed-Bold.ttf"
  pdf.bounding_box([50, pdf.cursor-10], :width => 470, :height => 30) do
    # pdf.stroke_bounds
    # pdf.fill_color = "FF0000"
    pdf.text "ГИДРОМЕТЕОРОЛОГИЧЕСКИЙ БЮЛЛЕТЕНЬ № #{@bulletin.curr_number}", :color => "0000FF", align: :center
    pdf.text @bulletin.report_date_as_str, :color => "0000FF", align: :center
  end

  if @bulletin.storm.present?
    pdf.bounding_box([0, pdf.cursor-10], :width => pdf.bounds.width) do
#    pdf.stroke_bounds
      pdf.text "ШТОРМОВОЕ ПРЕДУПРЕЖДЕНИЕ", align: :center, :color => "ff0000"
      pdf.font "./app/assets/fonts/OpenSans/OpenSans-Light.ttf"
      pdf.text @bulletin.storm
    end
  end
  pdf.move_down 10
  report_date_next = (@bulletin.report_date + 1.day).to_s(:custom_datetime)
  pdf.font "./app/assets/fonts/DejaVu/DejaVuSansCondensed-Bold.ttf"
  pdf.bounding_box([0, pdf.cursor], :width => pdf.bounds.width, :height => 30) do
    # pdf.stroke_bounds
    pdf.text "Прогноз погоды", align: :center, size: 14, :color => "0000FF"
    pdf.text "на сутки с 21 часа #{report_date[8,2]} #{month_name2(report_date[5,2])} до 21 часа #{report_date_next[8,2]} #{month_name2(report_date_next[5,2])} #{report_date_next[0,4]} года", align: :center, :color => "0000FF"
  end
  
  pdf.font_families.update("DejaVu" => {
    :normal => "./app/assets/fonts/DejaVu/DejaVuSans.ttf",
    :bold => "./app/assets/fonts/DejaVu/DejaVuSans-Bold.ttf"
  })
  #pdf.font "DejaVu"
  
  pdf.font_families.update(
    'OpenSans' => { :normal => "./app/assets/fonts/OpenSans/OpenSans-Regular.ttf",
                    :bold   => "./app/assets/fonts/OpenSans/OpenSans-Bold.ttf" }
  )
  pdf.font "OpenSans"
  # pdf.font "./app/assets/fonts/OpenSans/OpenSans-Light.ttf"
  # pdf.font "./app/assets/fonts/DejaVu/DejaVuSans.ttf"
  pdf.move_down 10
  # :shrink_to_fit
  table_content = [["<b>В Донецкой Народной Республике</b>", "<b>В городе Донецке</b>"],
                  [@bulletin.forecast_day, @bulletin.forecast_day_city]]
  pdf.table table_content, width: pdf.bounds.width,:cell_style => { :padding => 3, :inline_format => true, border_width: 0.3, border_color: "bbbbbb" }

  pdf.move_down 10
  pdf.text "Дежурный синоптик #{@bulletin.duty_synoptic}", align: :right
  # pdf.text "#{pdf.bounds.width}"

  pdf.move_down 10
  report_date_next2 = (@bulletin.report_date + 2.day).to_s(:custom_datetime)
  report_date_next3 = (@bulletin.report_date + 3.day).to_s(:custom_datetime)
  pdf.font "./app/assets/fonts/DejaVu/DejaVuSansCondensed-Bold.ttf"
  pdf.text "Периодный прогноз погоды на #{report_date_next2[8,2]}-#{report_date_next3[8,2]} #{month_name2(report_date_next3[5,2])} #{report_date_next3[0,4]} года", align: :center
  pdf.text "В Донецкой Народной Республике", align: :center
  pdf.font "./app/assets/fonts/OpenSans/OpenSans-Light.ttf"
  pdf.text @bulletin.forecast_period

  pdf.move_down 10
  report_date_next4 = (@bulletin.report_date + 4.day).to_s(:custom_datetime)
  report_date_next5 = (@bulletin.report_date + 5.day).to_s(:custom_datetime)
  pdf.font "./app/assets/fonts/DejaVu/DejaVuSansCondensed-Bold.ttf"
  pdf.text "Консультативный прогноз погоды на #{report_date_next4[8,2]}-#{report_date_next5[8,2]} #{month_name2(report_date_next5[5,2])} #{report_date_next5[0,4]} года", align: :center
  pdf.font "./app/assets/fonts/OpenSans/OpenSans-Light.ttf"
  pdf.text @bulletin.forecast_advice
  
  if @bulletin.forecast_orientation.present?
    pdf.move_down 10
    report_date_next6 = (@bulletin.report_date + 6.day).to_s(:custom_datetime)
    report_date_next11 = (@bulletin.report_date + 11.day).to_s(:custom_datetime)
    pdf.font "./app/assets/fonts/DejaVu/DejaVuSansCondensed-Bold.ttf"
    pdf.text "Ориентировочный прогноз погоды на #{report_date_next6[8,2]}-#{report_date_next11[8,2]} #{month_name2(report_date_next11[5,2])} #{report_date_next11[0,4]} года", align: :center
    pdf.font "./app/assets/fonts/OpenSans/OpenSans-Light.ttf"
    pdf.text @bulletin.forecast_orientation
  end
  pdf.text "Синоптик #{@bulletin.synoptic1}", align: :right



  pdf.start_new_page
  image1 = "./app/assets/images/head_of_dep.png"
  image2 = "./app/assets/images/chief.png"
  pdf.font "./app/assets/fonts/DejaVu/DejaVuSansCondensed-Bold.ttf"
  pdf.text "Приложение к Гидрометеорологическому Бюллетеню", align: :center, :color => "0000FF"
  pdf.text "от #{@bulletin.report_date_as_str} № #{@bulletin.curr_number}", align: :center, :color => "0000FF"
  
  pdf.move_down 10
  report_date_prev = (@bulletin.report_date - 1.day).to_s(:custom_datetime)
  pdf.text "МЕТЕОРОЛОГИЧЕСКИЕ ДАННЫЕ", align: :center, :color => "0000FF"
  pdf.text "за период с 9.00 часов #{report_date_prev[8,2]} #{month_name2(report_date_prev[5,2])} до 9.00 часов #{report_date[8,2]} #{month_name2(report_date[5,2])} #{report_date[0,4]} года", align: :center, :color => "0000FF"

  pdf.move_down 10
  m_d = []
  m_d = @bulletin.meteo_data.split(";") if @bulletin.meteo_data.present?
  if @bulletin.summer
    h7 = "Минимальная температура почвы" 
    h8 = "Минимальная относительная влажность воздуха (%)"
  else
    h7 = "Высота снежного покрова (см)"
    h8 = "Глубина промерзания (см)"
  end
  table_content = [["Название метеостанции", "<color rgb='ff0000'>Максимальная вчера днем</color>", "<color rgb='0000ff'>Минимальная сегодня ночью</color>", "Средняя за сутки #{report_date_prev[8,2]} #{month_name2(report_date_prev[5,2])}", "В 9.00 часов сегодня", "Количество осадков за сутки (мм)", h7, h8, "Максимальная скорость ветра (м/с)", "Явления погоды"],
                   ["Донецк",m_d[0], m_d[1], m_d[2], m_d[3], m_d[4], m_d[5], m_d[6], m_d[7], m_d[8]],
                   ["Дебальцево", m_d[9].present? ? m_d[9].strip : '', m_d[10], m_d[11], m_d[12], m_d[13], m_d[14], m_d[15], m_d[16], m_d[17]],
                   ["Амвросиевка", m_d[18].present? ? m_d[18].strip : '', m_d[19], m_d[20], m_d[21], m_d[22], m_d[23], m_d[24], m_d[25], m_d[26]],
                   ["Седово", m_d[27], m_d[28], m_d[29], m_d[30], m_d[31], m_d[32], m_d[33], m_d[34], m_d[35]]]

  pdf.font "./app/assets/fonts/OpenSans/OpenSans-Light.ttf"
  pdf.table table_content, width: pdf.bounds.width, :column_widths => [90, 40, 40, 40, 40, 40, 40, 55, 40],:cell_style => { :inline_format => true } do |t|
    t.cells.padding = [1, 1]
    t.cells.align = :center
    t.row(0).columns(1..8).rotate = 90
    t.row(0).height = 120
    t.row(0).column(0).valign = :center
    t.row(0).column(9).valign = :center
    # t.row(0).background_color = 'eeeeee'      
    # t.row(0).text_color = "FFFFFF"
  end
  
  pdf.move_down 10
  pdf.font "./app/assets/fonts/DejaVu/DejaVuSansCondensed-Bold.ttf"
  pdf.text "ОБЗОР ПОГОДЫ И АГРОМЕТЕОРОЛОГИЧЕСКИХ УСЛОВИЙ", align: :center, :color => "0000FF"
  pdf.text "в Донецкой Народной Республике", align: :center, :color => "0000FF"
  pdf.text "за период с 9.00 часов #{report_date_prev[8,2]} #{month_name2(report_date_prev[5,2])} до 9.00 часов #{report_date[8,2]} #{month_name2(report_date[5,2])} #{report_date[0,4]} года", align: :center, :color => "0000FF"
  pdf.font "./app/assets/fonts/OpenSans/OpenSans-Light.ttf"
  pdf.text @bulletin.agro_day_review  
  
  pdf.move_down 10
  pdf.font "./app/assets/fonts/DejaVu/DejaVuSansCondensed-Bold.ttf"
  c_d = []
  c_d = @bulletin.climate_data.split(";") if @bulletin.climate_data.present?
  pdf.text "Климатические данные по г. Донецку за #{report_date_prev[8,2]}-#{report_date[8,2]} #{month_name2(report_date[5,2])}", align: :center, :color => "0000FF"
  pdf.text "С 1945 по #{report_date[0,4]} гг. по данным Гидрометеорологической службы", align: :center, :color => "0000FF"
  table_content = [["Средняя за сутки температура воздуха", "#{report_date_prev[8,2]} #{month_name2(report_date_prev[5,2])}", c_d[0].present? ? c_d[0].strip : '', ""],
                   ["Максимальная температура воздуха", "#{report_date_prev[8,2]} #{month_name2(report_date_prev[5,2])}", c_d[1].present? ? c_d[1].strip : '', "отмечалась в #{c_d[2]} г."],
                   ["Минимальная температура воздуха", "#{report_date[8,2]} #{month_name2(report_date[5,2])}", c_d[3].present? ? c_d[3].strip : '', "отмечалась в #{c_d[4]} г."]]
  pdf.font "./app/assets/fonts/OpenSans/OpenSans-Light.ttf"
  pdf.table table_content, width: pdf.bounds.width
  pdf.move_down 10
  pdf.text "Время выпуска 13:00"
  
  pdf.move_down 10
  # e20 = "<b>Начальник</b>"
  e22 = "М.Б. Лукьяненко"
  table_content =[["Ответственный за выпуск:","","<b></b>"],
                  ["Начальник отдела гидрометеорологического обеспечения и обслуживания", {:image => image1, scale: 0.6}, "Л.Н. Бойко"],
                  ["Начальник", {:image => image2, scale: 0.6},e22]]
                  
  # pdf.font "./app/assets/fonts/DejaVu/DejaVuSansCondensed-Bold.ttf"                  
  # pdf.table table_content, width: pdf.bounds.width, cell_style: {:font => 'DejaVu'} {
#     values = cells.columns(1..-1).rows(1..-1)
#     values[1,1].font_style = :bold
#  }
  # pdf.font "./app/assets/fonts/OpenSans/OpenSans-Light.ttf"                
  # pdf.font "./app/assets/fonts/DejaVu/DejaVuSansCondensed-Bold.ttf"
  pdf.table table_content, width: pdf.bounds.width, :column_widths => [300, 100], cell_style: {:overflow => :shrink_to_fit, :font => 'DejaVu', :inline_format => true } do |t|
    t.cells.border_width = 0
  #   row(0).font_style = :bold
  #  t.cells.font_style  = :bold

  end
  
  pdf.font "./app/assets/fonts/DejaVu/DejaVuSansCondensed-Bold.ttf"
  string = "Страница <page>"
  # Green page numbers 1 to 7
  options = { :at => [pdf.bounds.right - 150, 0],
   :width => 150,
   :align => :right,
   :start_count_at => 1}
  pdf.number_pages string, options
  
end