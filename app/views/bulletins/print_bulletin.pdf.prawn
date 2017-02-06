prawn_document do |pdf|
  pdf.font "./app/assets/fonts/DejaVu/DejaVuSansCondensed-Bold.ttf"
  pdf.font "./app/assets/fonts/OpenSans/OpenSans-Light.ttf"
  y_pos = pdf.cursor
  pdf.image "./app/assets/images/logo.jpg", at: [0, pdf.cursor], :scale => 0.28
  pdf.bounding_box([80, y_pos], :width => 400, :height => 100) do
    # pdf.stroke_bounds
    pdf.text "МЧС ДНР", align: :center
    pdf.text "ГИДРОМЕТЕОРОЛОГИЧЕСКАЯ СЛУЖБА", align: :center
    pdf.text "МИНИСТЕРСТВА ПО ДЕЛАМ ГРАЖДАНСКОЙ ОБОРОНЫ, ЧРЕЗВЫЧАЙНЫМ", align: :center
    pdf.text "СИТУАЦИЯМ И ЛИКВИДАЦИИ ПОСЛЕДСТВИЙ СТИХИЙНЫХ БЕДСТВИЙ", align: :center
    pdf.text "ДОНЕЦКОЙ НАРОДНОЙ РЕСПУБЛИКИ", align: :center
    pdf.text "(ГМС МЧС ДНР)", align: :center
  end
  pdf.bounding_box([60, pdf.cursor], :width => 440, :height => 30) do
    # pdf.stroke_bounds
    pdf.text "ул. Любавина, 2, г. Донецк, 83015", align: :center, size: 10
    pdf.text "телефон: (062) 304-82-22, телефон/факс: (062) 304-99-25, e-mail: gidromet@mail.dnmchs.ru", align: :center, size: 10
  end
  pdf.font "./app/assets/fonts/DejaVu/DejaVuSansCondensed-Bold.ttf"
  pdf.bounding_box([100, pdf.cursor-10], :width => 360, :height => 30) do
    # pdf.stroke_bounds
    pdf.text "ГИДРОМЕТЕОРОЛОГИЧЕСКИЙ БЮЛЛЕТЕНЬ № #{@bulletin.curr_number}", align: :center
    pdf.text @bulletin.report_date_as_str, align: :center
  end

  report_date = @bulletin.report_date.to_s(:custom_datetime)
  report_date_next = (@bulletin.report_date + 1.day).to_s(:custom_datetime)
  pdf.bounding_box([60, pdf.cursor-10], :width => 440, :height => 30) do
    # pdf.stroke_bounds
    pdf.text "Прогноз погоды", align: :center, size: 14
    pdf.text "на сутки с 21 часа #{report_date[8,2]} #{month_name2(report_date[5,2])} до 21 часа #{report_date_next[8,2]} #{month_name2(report_date_next[5,2])} #{report_date_next[0,4]} года", align: :center
  end
  pdf.font "./app/assets/fonts/OpenSans/OpenSans-Light.ttf"
  pdf.move_down 10
  table_content = [["В Донецкой Народной Республике", "В городе Донецке"],
                  [@bulletin.forecast_day, @bulletin.forecast_day_city]]
  pdf.table table_content, width: pdf.bounds.width

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
  
  pdf.move_down 10
  report_date_next6 = (@bulletin.report_date + 6.day).to_s(:custom_datetime)
  report_date_next11 = (@bulletin.report_date + 11.day).to_s(:custom_datetime)
  pdf.font "./app/assets/fonts/DejaVu/DejaVuSansCondensed-Bold.ttf"
  pdf.text "Ориентировочный прогноз погоды на #{report_date_next6[8,2]}-#{report_date_next11[8,2]} #{month_name2(report_date_next11[5,2])} #{report_date_next11[0,4]} года", align: :center
  pdf.font "./app/assets/fonts/OpenSans/OpenSans-Light.ttf"
  pdf.text @bulletin.forecast_orientation
  pdf.text "Синоптик #{@bulletin.synoptic1}", align: :right

  pdf.start_new_page
  
  pdf.font "./app/assets/fonts/DejaVu/DejaVuSansCondensed-Bold.ttf"
  pdf.text "По акватории Азовского моря (на участке с. Безыменное – пгт. Седово)", align: :center

  pdf.move_down 10
  pdf.text "Прогноз погоды", align: :center
  pdf.text "с 21 часа #{report_date[8,2]} #{month_name2(report_date[5,2])} до 21 часа #{report_date_next[8,2]} #{month_name2(report_date_next[5,2])} #{report_date_next[0,4]} года", align: :center
  pdf.font "./app/assets/fonts/OpenSans/OpenSans-Light.ttf"
  pdf.text @bulletin.forecast_sea_day
  
  pdf.move_down 10
  pdf.font "./app/assets/fonts/DejaVu/DejaVuSansCondensed-Bold.ttf"
  pdf.text "Периодный прогноз погоды на #{report_date_next2[8,2]}-#{report_date_next3[8,2]} #{month_name2(report_date_next3[5,2])} #{report_date_next3[0,4]} года", align: :center
  pdf.font "./app/assets/fonts/OpenSans/OpenSans-Light.ttf"
  pdf.text @bulletin.forecast_sea_period
  pdf.text "Синоптик #{@bulletin.synoptic2}", align: :right
  pdf.text "Время выпуска 13:00"
  
  pdf.move_down 10
  image1 = "./app/assets/images/head_of_dep.png"
  image2 = "./app/assets/images/chief.png"
  table_content = [["Ответственный за выпуск: Начальник отдела гидрометеорологического обеспечения и обслуживания", {:image => image1, scale: 0.6}, "Л.Н. Бойко"],
                  ["Начальник", {:image => image2, scale: 0.6},"М.Б. Лукьяненко"]]
  pdf.table table_content, width: pdf.bounds.width, :column_widths => [300, 100] do |t|
    t.cells.border_width = 0
  end
  
  pdf.start_new_page
  pdf.font "./app/assets/fonts/DejaVu/DejaVuSansCondensed-Bold.ttf"
  pdf.text "Приложение к Гидрометеорологическому Бюллетеню", align: :center
  pdf.text "от #{@bulletin.report_date_as_str} № #{@bulletin.curr_number}", align: :center
  
  pdf.move_down 10
  report_date_prev = (@bulletin.report_date - 1.day).to_s(:custom_datetime)
  pdf.text "МЕТЕОРОЛОГИЧЕСКИЕ ДАННЫЕ", align: :center
  pdf.text "за период с 9.00 часов #{report_date_prev[8,2]} #{month_name2(report_date_prev[5,2])} до 9.00 часов #{report_date[8,2]} #{month_name2(report_date[5,2])} #{report_date[0,4]} года", align: :center

  pdf.move_down 10
  m_d = []
  m_d = @bulletin.meteo_data.split(";")
  table_content = [["Название метеостанции", "Максимальная вчера днем", "Минимальная сегодня ночью", "Средняя за сутки #{report_date_prev[8,2]} #{month_name2(report_date_prev[5,2])}", "В 9.00 часов сегодня", "Количество осадков за сутки (мм)", "Высота снежного покрова (см)", "Глубина промерзания (см)", "Максимальная скорость ветра (м/с)", "Явления погоды"],
                   ["Донецк",m_d[0], m_d[1], m_d[2], m_d[3], m_d[4], m_d[5], m_d[6], m_d[7], m_d[8]],
                   ["Дебальцево", m_d[9].strip, m_d[10], m_d[11], m_d[12], m_d[13], m_d[14], m_d[15], m_d[16], m_d[17]],
                   ["Амвросиевка", m_d[18].strip, m_d[19], m_d[20], m_d[21], m_d[22], m_d[23], m_d[24], m_d[25], m_d[26]]]
  pdf.font "./app/assets/fonts/OpenSans/OpenSans-Light.ttf"
  pdf.table table_content, width: pdf.bounds.width, :column_widths => [90, 40, 40, 40, 40, 40, 40, 40, 40] do |t|
    t.cells.padding = [1, 1]
    t.cells.align = :center
    t.row(0).columns(1..8).rotate = 90
    t.row(0).height = 100
    t.row(0).column(0).valign = :center
    t.row(0).column(9).valign = :center
    t.row(0).background_color = 'eeeeee'      
    # t.row(0).text_color = "FFFFFF"
  end
  
  pdf.move_down 10
  pdf.font "./app/assets/fonts/DejaVu/DejaVuSansCondensed-Bold.ttf"
  pdf.text "Обзор погоды и агрометеорологических условий", align: :center
  pdf.text "в Донецкой Народной Республике", align: :center
  pdf.text "за период с 9.00 часов #{report_date_prev[8,2]} #{month_name2(report_date_prev[5,2])} до 9.00 часов #{report_date[8,2]} #{month_name2(report_date[5,2])} #{report_date[0,4]} года", align: :center
  pdf.font "./app/assets/fonts/OpenSans/OpenSans-Light.ttf"
  pdf.text @bulletin.agro_day_review  
  
  pdf.move_down 10
  pdf.font "./app/assets/fonts/DejaVu/DejaVuSansCondensed-Bold.ttf"
  c_d = []
  c_d = @bulletin.climate_data.split(";")
  pdf.text "Климатические данные по г. Донецку за #{report_date_prev[8,2]}-#{report_date[8,2]} #{month_name2(report_date[5,2])}", align: :center
  pdf.text "С 1945 по #{report_date[0,4]} гг. по данным Гидрометеорологической службы", align: :center
  table_content = [["Средняя за сутки температура воздуха", "#{report_date_prev[8,2]} #{month_name2(report_date_prev[5,2])}", c_d[0].strip, ""],
                   ["Максимальная температура воздуха", "#{report_date_prev[8,2]} #{month_name2(report_date_prev[5,2])}", c_d[1].strip, "отмечалась в #{c_d[2]} г."],
                   ["Минимальная температура воздуха", "#{report_date[8,2]} #{month_name2(report_date[5,2])}", c_d[3].strip, "отмечалась в #{c_d[4]} г."]]
  pdf.font "./app/assets/fonts/OpenSans/OpenSans-Light.ttf"
  pdf.table table_content, width: pdf.bounds.width
  pdf.move_down 10
  pdf.text "Время выпуска 13:00"
  
  pdf.move_down 10
  table_content = [["Ответственный за выпуск: Начальник отдела гидрометеорологического обеспечения и обслуживания", {:image => image1, scale: 0.6}, "Л.Н. Бойко"],
                  ["Начальник", {:image => image2, scale: 0.6},"М.Б. Лукьяненко"]]
  pdf.table table_content, width: pdf.bounds.width, :column_widths => [300, 100] do |t|
    t.cells.border_width = 0
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