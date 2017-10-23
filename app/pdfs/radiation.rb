require 'prawn'
class Radiation < Prawn::Document
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
    move_down 30
    font "OpenSans", style: :bold
    bounding_box([50, cursor], :width => 470) do
      text @bulletin.report_date.to_s+" № "+@bulletin.curr_number
    end
    move_down 20
    image "./app/assets/images/rhumbs.png", at: [0, cursor]
    font "OpenSans", style: :italic
    bounding_box([300, cursor], width: bounds.width-300) do
      text "Начальнику центра управления в кризисных ситуациях Министерства по делам гражданской обороны, чрезвычайным ситуациям и ликвидации последствий стихийных бедствий 
      Донецкой Народной Республики
      
      В.В. Вовку"
    end
    move_down 20
    text "Сообщаем данные о состоянии радиационного фона (мкР/ч) на 09.00 часов <b>#{@bulletin.report_date_as_str}</b>:", :inline_format => true, :indent_paragraphs => 40
    m_d = []
    m_d = @bulletin.meteo_data.split(";") if @bulletin.meteo_data.present?
    move_down 20
    table [["Метеорологическая станция",	"Донецк", "Дебальцево",	"Амвросиевка",	"Седово"],
            ["мкР/ч", m_d[0], m_d[1], m_d[2], m_d[3]]], width: bounds.width,:cell_style => { :align => :center, :inline_format => true}
    move_down 20
    avg = (m_d[0].to_i+m_d[1].to_i+m_d[2].to_i+m_d[3].to_i) / 4
    text "Средний радиационный фон по Республике #{avg} мкР/ч."
    bounding_box([0, 150], width: bounds.width) do
      text "Ответственный за выпуск:"
      table [["Начальник отдела гидрометеорологического обеспечения и обслуживания", {image: "./app/assets/images/head_of_dep.png", scale: 0.6},"Л.Н. Бойко"]], width: bounds.width, column_widths:  [300, 100], cell_style: {overflow: :shrink_to_fit, inline_format: true } do |t|
        t.cells.border_width = 0
      end
    end
    text_box @bulletin.synoptic1, :at => [0, 30], :width => 170
    image "./app/assets/images/radiation.png", at: [440, 100], :scale => 0.75
    text_box "телефон: (062) 304-82-22", :at => [350, 30], :width => 170, align: :right
    move_to 0, 15
    line_to 550, 15
    stroke_color '0000ff'
    stroke
  end
end