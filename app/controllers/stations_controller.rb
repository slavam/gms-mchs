class StationsController < ApplicationController
  def index
    @stations = Station.all.order(:name)
  end
  
end