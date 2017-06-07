class MaterialsController < ApplicationController
  def index
    @materials = Material.all.order(:id)
  end
end
