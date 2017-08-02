class SynopticObservationsController < ApplicationController
  before_filter :require_observer
  
  def new
    @last_telegrams = SynopticObservation.all.limit(50).order(:date, :term).reverse_order
  end
  
  private
    def require_observer
      if current_user and (current_user.role == 'observer')
      else
        flash[:danger] = 'Вход только для наблюдателей'
        redirect_to login_path
        return false
      end
    end
end
