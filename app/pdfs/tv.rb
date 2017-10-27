require 'prawn'
class Tv < Prawn::Document
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
    image "./app/assets/images/eagle.png", at: [200, y_pos], :scale => 0.75
    font "OpenSans", style: :bold
    move_down 110
    bounding_box([50, cursor], :width => 470) do
      text Bulletin::HEAD, align: :center, size: 10
    end
    move_down 10
    font "OpenSans", style: :italic
    bounding_box([50, cursor], :width => 470) do
      text Bulletin::ADDRESS, align: :center, size: 10
    end
    move_down 10
    font "OpenSans", style: :normal
    text @bulletin.created_at.to_s(:custom_datetime)
    bounding_box([350, cursor], width: bounds.width-300) do
      text "Генеральному директору
            Первого республиканского
            канала ДНР
		
            Петренко В.Е."
    end
    move_down 10
    text "Гидрометеорологический центр МЧС ДНР сообщает прогноз погоды по следующим городам на <b>#{@bulletin.report_date_as_str}</b>:", :inline_format => true, :indent_paragraphs => 40
    text @bulletin.forecast_day
    
    move_down 10
    table temps, width: bounds.width,:cell_style => { :align => :center, :inline_format => true, :padding => [2, 2, 2, 2], :size => 10}
    text_box @bulletin.synoptic1, :at => [0, 15], :width => 170
  end
  def temps
    ret = [["<b>Город</b>",	"<b>Температура воздуха ночью</b>", "<b>Температура воздуха днем</b>"]]
    m_d = []
    m_d = @bulletin.meteo_data.split(";") if @bulletin.meteo_data.present?
    i = 0
    Bulletin::TV_CITIES.each do |c|
      ret << [c, m_d[i*2], m_d[i*2+1]]
      i += 1
    end
    return ret
  end
end