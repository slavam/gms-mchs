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
*/  
