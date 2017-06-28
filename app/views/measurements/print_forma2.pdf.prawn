prawn_document(:page_layout => :landscape, :page_size => "A3") do |pdf|
  # pdf.font "./app/assets/fonts/OpenSans/OpenSans-Light.ttf"
  pdf.font "./app/assets/fonts/DejaVu/DejaVuSansCondensed-Bold.ttf"
  pdf.text "Форма 2"
  pdf.move_down 5
  pdf.text "Характеристика загрязнения атмосферного воздуха"
  pdf.move_down 5
  pdf.text "за период с #{@date_from} по #{@date_to}"
  pdf.move_down 5
  pdf.text @scope_name
  
  # width pdf.bounds.width
  pdf.font "./app/assets/fonts/OpenSans/OpenSans-Light.ttf"
  pdf.table @pollutions, width: 1030, :column_widths => [30, 130, 30, 50, 70, 40, 70, 40, 50, 50, 40, 40, 50, 40, 40, 50, 50, 50, 50] do |t|
    t.cells.padding = [3, 3]
    t.cells.align = :center
    # t.row(0..1).align = :center
    t.row(1).height = 80
    t.row(2..99).column(1).align = :left if t.row(2).present?
    t.row(0).background_color = 'eeeeee'      
  end
  
  pdf.move_down 5
  pdf.text " Всего примесей #{@total_materials}"
  pdf.move_down 5
  pdf.text " Всего измерений #{@total_pollutions}"
  
  # pdf.font "Times-Roman"  
  # pdf.font "./app/assets/fonts/DejaVu/DejaVuSans-ExtraLight.ttf"
  # pdf.table [[@pollutions]]
end  