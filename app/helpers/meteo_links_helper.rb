module MeteoLinksHelper
  def active_meteo_links
    @active_meteo_links = MeteoLink.where("is_active = true").order(:name)
  end
end
