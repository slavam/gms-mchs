require 'prawn'
class ChemForma1AsProtocol < Prawn::Document
  def initialize(year, month, post_id, pollutions, site_description)
		super(top_margin: 40)		
		@year = year
		@month = month
		
		report_date = Time.now.strftime("%Y-%m-%d")
		font_families.update("OpenSans" => {
      :normal => Rails.root.join("./app/assets/fonts/OpenSans/OpenSans-Regular.ttf"),
      :italic => Rails.root.join("app/assets/fonts/OpenSans/OpenSans-Italic.ttf"),
      :bold => Rails.root.join("./app/assets/fonts/OpenSans/OpenSans-Bold.ttf"),
      :bold_italic => Rails.root.join("app/assets/fonts/OpenSans/OpenSans-BoldItalic.ttf")
    })
    y_pos = cursor
    font "OpenSans", style: :bold
    # start_new_page layout: :landscape
    bounding_box([0, y_pos], :width => bounds.width) do
      text "ПРОТОКОЛ № ___", align: :center, size: 14
      move_down 5
      text "измерений содержания загрязняющих веществ в атмосферном воздухе", align: :center
      text "от #{report_date[8,2]} #{Bulletin::MONTH_NAME2[report_date[5,2].to_i]} #{report_date[0,4]}г.", align: :center
    end
    move_down 5
    text "Год #{@year}. Месяц #{@month}"
    text site_description
    move_down 10
    font "OpenSans", style: :normal
    table pollutions, cell_style: { border_width: 0.3, :overflow => :shrink_to_fit, :font => 'OpenSans', :inline_format => true, size: 9 }, :column_widths => {0 =>65, 1 => 35, 2 => 45} do |t|
      # t.cells.border_width = 0
    end
    move_down 10
    font "OpenSans", style: :bold
    if post_id.to_i > 14 
      text "Начальник ЛНЗА г. Горловка: _____________________ / Е.А. Фетисова/"
      move_down 5
      text "Исполнитель: ___________________________________/ Ю.Ю. Сидоренко/"
    else
      text "Начальник ЛНЗА г. Донецк: _____________________ /               /"
      move_down 5
      text "Исполнитель: ___________________________________/               /"
    end
  end
end