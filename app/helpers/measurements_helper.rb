module MeasurementsHelper
  def calc_volume(measurement, material_id)
    post = Post.find(measurement.post_id)
    chem_coefficient = ChemCoefficient.find_by(material_id: material_id, laboratory_id: post.laboratory_id)
    k = (measurement.atmosphere_pressure / 1.334) / (measurement.temperature + 273.0) * 0.359
    material_id == 1 ? (k*post.sample_volume_dust).round(3) : (chem_coefficient.present? ? (k*chem_coefficient.sample_volume).round(3) : 0)
  end
end
