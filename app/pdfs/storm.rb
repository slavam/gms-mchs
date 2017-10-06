require 'prawn'
class Storm < Prawn::Document
  def initialize(bulletin)
		super(top_margin: 40)		
		@bulletin = bulletin
    font_families.update("OpenSans" => {
      :normal => Rails.root.join("./app/assets/fonts/OpenSans/OpenSans-Regular.ttf"),
      :italic => Rails.root.join("app/assets/fonts/OpenSans/OpenSans-Italic.ttf"),
      :bold => Rails.root.join("./app/assets/fonts/OpenSans/OpenSans-Bold.ttf"),
      :bold_italic => Rails.root.join("app/assets/fonts/OpenSans/OpenSans-BoldItalic.ttf")
    })
    y_pos = cursor
    image "./app/assets/images/logo.jpg", at: [0, y_pos], :scale => 0.25
    font "OpenSans", style: :bold
    bounding_box([50, y_pos], :width => 470) do
      text Bulletin::HEAD, align: :center
    end
    move_down 20
    font "OpenSans", style: :italic
    bounding_box([50, cursor], :width => 470) do
      text Bulletin::ADDRESS, align: :center, size: 10
    end
    move_down 80
    font "OpenSans", style: :bold
    text @bulletin.date_hour_minute
    move_down 20
    bounding_box([0, cursor], width: bounds.width) do
      text "ШТОРМОВОЕ ПРЕДУПРЕЖДЕНИЕ № #{@bulletin.curr_number}", align: :center, color: "ff0000"
    end
    move_down 10
    font "OpenSans"
    text_box @bulletin.storm, :at => [0, cursor], :width => bounds.width, :height => 300, :overflow => :shrink_to_fit
    move_down 20
    bounding_box([0, 150], width: bounds.width) do
      table [["<b>Начальник</b>", {image: "./app/assets/images/chief.png", scale: 0.6},"<b>М.Б. Лукьяненко</b>"]], width: bounds.width, column_widths:  [300, 100], cell_style: {overflow: :shrink_to_fit, inline_format: true } do |t|
        t.cells.border_width = 0
      end
    end
    text_box @bulletin.synoptic1, :at => [0, 30], :width => 170
    image "./app/assets/images/storm.png", at: [450, 100], :scale => 0.75
    text_box "телефон: (062) 304-82-22", :at => [350, 30], :width => 170, align: :right
    move_to 0, 15
    line_to 550, 15
    stroke_color '0000ff'
    stroke
  end
end