class Measurement < ActiveRecord::Base
  belongs_to :post
  has_many :pollution_values, :dependent => :destroy
  
  def self.get_id_by_date_term_post(date, term, post)
    ms = Measurement.where("date = ? AND term = ? AND post_id = ?", date, term, post)
    if ms.count == 0
      return nil
    else
      return ms[0].id
    end
  end
end
