require 'prawn'
class Meteoparams < Prawn::Document
  def initialize(meteoparams, year, month, station_name)
		super(top_margin: 40)		
		@meteoparams = meteoparams
		@year = year
		@month = month
		@station_name = station_name
    font_families.update("OpenSans" => {
      :normal => Rails.root.join("./app/assets/fonts/OpenSans/OpenSans-Regular.ttf"),
      :italic => Rails.root.join("app/assets/fonts/OpenSans/OpenSans-Italic.ttf"),
      :bold => Rails.root.join("./app/assets/fonts/OpenSans/OpenSans-Bold.ttf"),
      :bold_italic => Rails.root.join("app/assets/fonts/OpenSans/OpenSans-BoldItalic.ttf")
    })
    y_pos = cursor
    font "OpenSans", style: :bold
    bounding_box([0, y_pos], :width => bounds.width) do
      text "Таблица наблюдений за метеопараметрами", align: :center, size: 16
    end
    move_down 10
    text "Год: #{@year}. Месяц: #{@month}. Метеостанция: #{@station_name}", size: 12
    move_down 20
    font "OpenSans", style: :normal
    table meteodata, width: bounds.width, :column_widths => [60, 35, 60, 65, 60, 180,80], cell_style: { border_width: 0.3, :overflow => :shrink_to_fit, :font => 'OpenSans', :inline_format => true, size: 9 } do |t|
      # t.cells.border_width = 0
    end
    move_down 10
    text "Число замеров: #{@meteoparams.size}"
  end
  
  def meteodata
    table = []
    @meteoparams.each do |mp|
      row = []
      row << mp[:date]
      row << mp[:term]
      row << mp[:temperature]
      row << mp[:wind_direction]
      row << mp[:wind_speed_avg]
      row << mp[:weather]
      row << mp[:pressure]
      table << row
    end
    [
      ['<b>Дата</b>','<b>Срок</b>', '<b>Температура, °С</b>', '<b>Направление ветра, °</b>', '<b>Скорость ветра, м/с</b>', '<b>Атмосферные явления</b>', '<b>Атмосферное давление, hPa/мм.рт.ст.</b>']
    ] + table
  end
end