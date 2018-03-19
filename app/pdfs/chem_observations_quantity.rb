require 'prawn'
class ChemObservationsQuantity < Prawn::Document
  def initialize(observations, date_from, date_to, total, city_name, city_id, materials, posts)
		super(top_margin: 40)		
		@observations = observations
		@materials = materials
		@posts = posts
		@city_id = city_id
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
      text "Отчет о количестве наблюдений выполненных на постах контроля за загрязнением атмосферного воздуха", align: :center, size: 16
    end
    move_down 10
    text "Период времени с #{date_from} по #{date_to}", size: 12
    move_down 10
    text "Город #{city_name}", size: 12
    move_down 20
    font "OpenSans", style: :normal
    table observations_table, width: bounds.width, cell_style: { border_width: 0.3, :overflow => :shrink_to_fit, :font => 'OpenSans', :inline_format => true, size: 9 } do |t|
      # t.cells.border_width = 0
    end
    move_down 10
    text "Всего по городу: #{total}"
	end
	def observations_table
    header = ['<b>Вещества</b>']
    @posts.each {|p| header << '<b>'+p.short_name+'</b>' if p.city_id == @city_id.to_i} 
    header << '<b>Всего</b>'
    table = []
    @materials.each do |m|
      row = []
      row << '<b>'+m.name+'</b>'
      s = 0
      @posts.each do |p|
        if p.city_id == @city_id.to_i
          row << @observations[[m.id,p.id]] 
          s += @observations[[m.id,p.id]] 
        end
      end
      row << '<b>'+s.to_s+'</b>'
      table << row
    end
    [header]+table
  end
end