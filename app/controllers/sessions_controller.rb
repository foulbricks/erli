class SessionsController < ApplicationController
  skip_before_filter :authorize
  
  def new
    session[:user_id] = nil
  end
  
  def create
    user = User.authenticate(params[:login][:email], params[:login][:password])
    
    if user && user.active?
      session[:user_id] = user.id
      cookies[:building] = user.building.try(:id) if !user.admin?
      redirect_to root_url
    else
      flash.now.alert = "Email e/o password non validi"
      render "new"
    end
  end
  
  def destroy
    session[:user_id] = nil
    cookies[:building] = nil
    redirect_to new_session_path, notice: "E stato uscito con successo"
  end
  
  private
  
  def login_params
    params.require(:login).permit(:email, :password)
  end
end
