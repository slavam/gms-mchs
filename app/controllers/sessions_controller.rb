class SessionsController < ApplicationController
  def new
  end
  
  def create
    user = User.find_by(login: params[:session][:login])
    if user && user.authenticate(params[:session][:password])
      # Log the user in and redirect to the user's show page.
      log_in user
      remember user
      redirect_to user
    else
      flash.now[:danger] = 'Ошибочная login/password комбинация'
      render 'new'
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
