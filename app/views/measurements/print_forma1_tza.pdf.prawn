prawn_document(:page_layout => :landscape, :page_size => "A3") do |pdf|
  # pdf.font "./app/assets/fonts/OpenSans/OpenSans-Light.ttf"
  pdf.font "./app/assets/fonts/DejaVu/DejaVuSansCondensed-Bold.ttf"
  pdf.text "Форма 1"
  pdf.move_down 5
  pdf.text "Таблица наблюдений за загрязнением атмосферы"
  pdf.move_down 5
  pdf.text "Год #{@year}. Месяц #{@month}"
  pdf.move_down 5
  pdf.text @matrix[:site_description]
  pdf.table @pollutions, width: pdf.bounds.width do |t|
  
  end
end