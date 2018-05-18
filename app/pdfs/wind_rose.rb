require 'prawn'
class WindRose < Prawn::Document
# class WindRose
  # include Prawn::View
  def initialize(matrix, city_name, year, user_id)
		super(top_margin: 40)		
		@matrix = matrix
    font_families.update("OpenSans" => {
      :normal => Rails.root.join("./app/assets/fonts/OpenSans/OpenSans-Regular.ttf"),
      :italic => Rails.root.join("app/assets/fonts/OpenSans/OpenSans-Italic.ttf"),
      :bold => Rails.root.join("./app/assets/fonts/OpenSans/OpenSans-Bold.ttf"),
      :bold_italic => Rails.root.join("app/assets/fonts/OpenSans/OpenSans-BoldItalic.ttf")
    })
    y_pos = cursor
    font "OpenSans", style: :bold
    bounding_box([0, y_pos], :width => bounds.width) do
      text "Повторяемость штилей и направлений ветра по городу #{city_name} по данным наблюдений репрезентативной метеорологической станции за #{year} год", align: :center, size: 16
    end
    move_down 20
    font "OpenSans", style: :normal
    table winddata, width: bounds.width, cell_style: { border_width: 0.3, :overflow => :shrink_to_fit, :font => 'OpenSans', :inline_format => true, size: 9 } do |t|
      # t.cells.border_width = 0
    end
    move_down 20
    if Rails.env.production?
      image_name = "#{Rails.root}/public/images/wind_rose_#{user_id}.png"
    else
      image_name = "app/assets/pdf_folder/wind_rose_#{user_id}.png"
    end
    # image "./app/assets/pdf_folder/wind_rose_#{user_id}.png", at: [-120, cursor], :scale => 0.7
    image image_name, at: [0, cursor], :scale => 0.5
  end
  def winddata
    table = []
    period = ['Год','Январь','','','','','','Июль']
    [0,1,7].each do |j|
      row = []
      row[0] = period[j]
      (0..8).each { |i| row << (@matrix[[j, i]] > 0 ? @matrix[[j, i]].round(2) : '')}
      table << row
    end
    [
      ['<b>Период</b>','<b>С</b>', '<b>СВ</b>', '<b>В</b>', '<b>ЮВ</b>', '<b>Ю</b>', '<b>ЮЗ</b>', '<b>З</b>', '<b>СЗ</b>', '<b>Штиль</b>']
    ] + table
  end
end