class SessionsController < ApplicationController
  skip_before_filter :authorize
  
  def new
    
  end
  
  def create
    user = User.authenticate(params[:login][:email], params[:login][:password])
    
    if user && user.active?
      session[:user_id] = user.id
      redirect_to root_url
    else
      flash.now.alert = "Invalid username and/or password"
      render "new"
    end
  end
  
  def destroy
    session[:user_id] = nil
    redirect_to new_session_path, notice: "You have successfully logged out"
  end
  
  private
  
  def login_params
    params.require(:login).permit(:email, :password)
  end
end
