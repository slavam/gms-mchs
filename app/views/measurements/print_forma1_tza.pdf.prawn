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
  pdf.text "ПРОТОКОЛ № ___", align: :center, size: 12
  pdf.move_down 5
  pdf.text "измерений содержания загрязняющих веществ в атмосферном воздухе", align: :center
  pdf.text "от #{report_date[8,2]} #{Bulletin::MONTH_NAME2[report_date[5,2].to_i]} #{report_date[0,4]}г.", align: :center
  pdf.move_down 5
  pdf.text "Год #{@year}. Месяц #{@month}"
  pdf.text @matrix[:site_description]
  pdf.move_down 5
  pdf.font "OpenSans", style: :normal, size: 8
  pdf.table @pollutions, width: pdf.bounds.width, cell_style: { :inline_format => true}, :column_widths => [70, 30, 40, 70, 60, 70, 50, 50] do |t|
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