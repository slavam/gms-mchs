require 'prawn'
class ChemForma1AsProtocol < Prawn::Document
  def initialize(year, month)
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
    move_down 10
  end
end