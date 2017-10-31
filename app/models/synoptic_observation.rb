class SynopticObservation < ActiveRecord::Base
  validates :date, presence: true
  validates :term, presence: true
  validates :station_id, presence: true
  validates :telegram, presence: true
  belongs_to :station
  audited
  
  def self.last_50_telegrams
    SynopticObservation.all.limit(50).order(:date, :term, :updated_at).reverse_order
  end
  
  def self.short_last_50_telegrams
    all_fields = SynopticObservation.all.limit(50).order(:date, :term, :updated_at).reverse_order
    stations = Station.all.order(:id)
    all_fields.map do |rec|
      {id: rec.id, date: rec.date, term: rec.term, station_name: stations[rec.station_id-1].name, telegram: rec.telegram}
    end
  end
  
  def wind_direction_to_s
    case self.wind_direction
      when 0
        "Штиль"
      when 1..2
        "Северо-северо-восточное"
      when 3..5
        "Северо-восточное"
      when 6..7
        "Восточно-северо-восточное"
      when 8..9
        "Восточное"
      when 10..11
        "Восточно-юго-восточное"
      when 12..14
        "Юго-восточное"
      when 15..16
        "Юго-юго-восточное"
      when 17..18
        "Южное"
      when 19..20
        "Юго-юго-западное"
      when 21..23
        "Юго-западное"
      when 24..25
        "Западно-юго-западное"
      when 26..27
        "Западное"
      when 28..29
        "Западно-северо-западное"
      when 30..32
        "Северо-западное"
      when 33..34
        "Северо-северо-западное"
      when 35..36
        "Северное"
      when 99
        "Переменное"
      else
        self.wind_direction.to_s
    end
  end
    
  def visibility
    return "Видимость не определена" if self.visibility_range.nil?
    case self.visibility_range
      when 0
        "< 0,1 км."
      when 1..50
        "до 5 км."
      when 56..80
        "от 6 км. до 30 км."
      when 81..88
        "от 35 км. до 70 км."
      when 89
        "> 70 км."
      when 90
        " менее 50 метров"
      when 91
        " 50 метров"
      when 92
        " 200 метров"
      when 93
        " 500 метров"
      when 94 
        " 1 километр"
      when 95 
        " 2 километра"
      when 96
        " 4 километра"
      when 97
        " 10 километров"
      when 98
        " 20 километров"
      when 99
        " более 50 километров"
      else
        self.visibility_range.to_s
    end
  end
  
  def cloud_base_height_to_s
    return "Нижняя граница не определенна" if self.cloud_base_height.nil?
    case self.cloud_base_height
      when 0
        "< 50"
      when 1
        "50-100"
      when 2
        "100-200"
      when 3
        "200-300"
      when 4
        "300-600"
      when 5
        "600-1000"
      when 6
        "1000-1500"
      when 7
        "1500-2000"
      when 8
        "2000-2500"
      when 9
        "> 2500 или облаков нет"
    end
  end
  
  def cloud_amount(c_a)
    return 'Определить невозможно или наблюдения не производились' if c_a.nil?
    case c_a
      when 0
        "0 (облаков нет)"
      when 1
        '<=1 (но не 0)'
      when 2
        '2-3'
      when 3
        '4'
      when 4
        '5'
      when 5
        '6'
      when 6
        '7-8'
      when 7
        '>= 9 (но не 10, есть просветы)'
      when 8
        '10 (без просветов)'
      when 9
        'Определить невозможно (затруднена видимость)'
    end
  end
  
  def pressure_tendency_characteristic_to_s
    return '' if self.pressure_tendency_characteristic.nil?
    case self.pressure_tendency_characteristic
      when 0
        "рост, затем падение"
      when 1
        " рост "
      when 2
        " рост "
      when 3
        " рост "
      when 4
        "ровный или неровный ход"
      when 5
        "падение, затем рост"
      when 6
        "падение"
      when 7
        "падение"
      when 8
        "падение"
    end
  end

  def clouds_1_to_s
    return 'Облака CL не видны' if self.clouds_1.nil?
    case self.clouds_1
      when 0
        'Облака CL отсутствуют'
      when 1,2
        'Кучевые'
      when 3,9
        'Кучеводождевые'
      when 4,5
        'Слоистокучевые'
      when 6,7
        'Слоистые'
      when 8
        'Кучевые и слоистокучевые'
    end
  end
  
  def clouds_2_to_s
    return 'Облака CM не видны' if self.clouds_2.nil?
    case self.clouds_2
      when 0
        'Облака CM отсутствуют'
      when 1
        'Высокослоистые'
      when 2
        'Высокослоистые, слоисто-дождевые'
      when 3,5,6,7,8,9
        'Высококучевые'
    end
  end

  def clouds_3_to_s
    return 'Облака CH не видны' if self.clouds_3.nil?
    case self.clouds_3
      when 0
        'Облака CH отсутствуют'
      when 1..4
        'Перистые'
      when 5..8
        'Перисто-слоистые'
      when 9
        'Перисто-кучевые'
    end
  end
  
  def soil_surface_condition_1_to_s
    case self.soil_surface_condition_1
      when 0
        'Сухая'
      when 1
        'Влажная (без луж)'
      when 2
        'Влажная (с лужами)'
      when 3
        'Затоплена водой'
      when 4
        'Замерзшая'
      when 5
        'Покрыта льдом'
      when 6
        'Покрыта сухой пылью'
      when 7
        'Покрыта сухой пылью полностью (тонкий слой)'
      when 8
        'Покрыта сухой пылью полностью (умеренный или толстый слой)'
      when 9
        'Сухая чрезвычайно'
    end
  end
  
  def precipitation_1_to_s
    case self.precipitation_1
        when 1..988
          self.precipitation_1.to_s
        when 989
          "989 и больше"
        when 990
          "следы осадков"
        when 991..999
          ((self.precipitation_1 - 990)*0.1).to_s
      end
  end
end
