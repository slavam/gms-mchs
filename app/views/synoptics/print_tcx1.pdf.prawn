prawn_document(:page_layout => :landscape, :page_size => "A3") do |pdf|
  # pdf.font "./app/assets/fonts/OpenSans/OpenSans-Light.ttf"
  pdf.font "./app/assets/fonts/DejaVu/DejaVuSansCondensed-Bold.ttf"
  pdf.text "Таблица для обработки агрометеорологических наблюдений за #{month_name(@month)} #{@year} года"
  pdf.move_down 5
  pdf.text "Средняя температура воздуха, °С"
  pdf.move_down 5
  
  # pdf.font "Times-Roman"  
  pdf.font "./app/assets/fonts/DejaVu/DejaVuSans-ExtraLight.ttf"
  pdf.table [[@matrix]]
  pdf.font "./app/assets/fonts/DejaVu/DejaVuSansCondensed-Bold.ttf"
  pdf.move_down 25
  pdf.text "Максимальная температура воздуха, °С"
  pdf.move_down 5
  pdf.font "./app/assets/fonts/DejaVu/DejaVuSans-ExtraLight.ttf"
  pdf.table [[@matrix_max_temps]]
  pdf.move_down 25
  pdf.font "./app/assets/fonts/DejaVu/DejaVuSansCondensed-Bold.ttf"
  pdf.text "Минимальная температура воздуха, °С"
  pdf.move_down 5
  pdf.font "./app/assets/fonts/DejaVu/DejaVuSans.ttf"
  pdf.table [[@matrix_min_temps]]
  
  pdf.start_new_page
  pdf.font "./app/assets/fonts/DejaVu/DejaVuSansCondensed-Bold.ttf"
  pdf.text "Максимальная скорость ветра, м/с"
  pdf.move_down 5
  pdf.font "./app/assets/fonts/DejaVu/DejaVuSans.ttf"
  pdf.table [[@matrix_max_wind_speed]]
  pdf.move_down 5
  pdf.font "./app/assets/fonts/DejaVu/DejaVuSansCondensed-Bold.ttf"
  pdf.text "Количество осадков, мм"
  pdf.move_down 5
  pdf.font "./app/assets/fonts/DejaVu/DejaVuSans.ttf"
  pdf.table [[@matrix_rainfall]]
  pdf.move_down 5
  pdf.font "./app/assets/fonts/DejaVu/DejaVuSansCondensed-Bold.ttf"
  pdf.text "Минимальная температура почвы, °С"
  pdf.move_down 5
  pdf.font "./app/assets/fonts/DejaVu/DejaVuSans.ttf"
  pdf.table [[@matrix_min_soil_temps]]
  pdf.move_down 5
  pdf.font "./app/assets/fonts/DejaVu/DejaVuSansCondensed-Bold.ttf"
  pdf.text "Минимальная относительная влажность воздуха, %"
  pdf.move_down 5
  pdf.font "./app/assets/fonts/DejaVu/DejaVuSans.ttf"
  pdf.table [[@matrix_min_humidity]]

end