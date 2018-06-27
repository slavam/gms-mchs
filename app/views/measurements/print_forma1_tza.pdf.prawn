prawn_document(:page_size => "A4") do |pdf|
  pdf.font_families.update("OpenSans" => {
      :normal => Rails.root.join("./app/assets/fonts/OpenSans/OpenSans-Regular.ttf"),
      :italic => Rails.root.join("app/assets/fonts/OpenSans/OpenSans-Italic.ttf"),
      :bold => Rails.root.join("./app/assets/fonts/OpenSans/OpenSans-Bold.ttf"),
      :bold_italic => Rails.root.join("app/assets/fonts/OpenSans/OpenSans-BoldItalic.ttf")
    })
  report_date = Time.now.strftime("%Y-%m-%d")
  pdf.font "./app/assets/fonts/DejaVu/DejaVuSansCondensed-Bold.ttf"
#  pdf.font "./app/assets/fonts/OpenSans/OpenSans-Light.ttf"
  pdf.text "Форма 1", size: 14
  pdf.move_down 5
  pdf.text "Таблица наблюдений за загрязнением атмосферы", align: :center
  pdf.move_down 5
  pdf.text "Год #{@year}. Месяц #{@month}"
  pdf.text @matrix[:site_description]
  pdf.move_down 5
  pdf.font "OpenSans", style: :normal, size: 8
  pdf.table @pollutions, cell_style: { :inline_format => true}, :column_widths => {0 =>70, 1 => 30, 2 => 40} do |t|
  end
  pdf.move_down 10
  pdf.font "OpenSans", style: :bold
  if @post_id.to_i > 14 
    pdf.text "Начальник ЛНЗА г. Горловка: _____________________ / Е.А. Фетисова/"
    pdf.move_down 5
    pdf.text "Исполнитель: ___________________________________/ Ю.Ю. Сидоренко/"
  else
    pdf.text "Начальник ЛНЗА г. Донецк: _____________________ /               /"
    pdf.move_down 5
    pdf.text "Исполнитель: ___________________________________/               /"
  end
  
end