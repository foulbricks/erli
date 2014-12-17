class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  before_filter :authorize
  
  protect_from_forgery with: :exception
  
  def authorize
    if !session[:user_id]
      redirect_to new_session_path
    end
  end
  
  def check_admin
    user = User.find(session[:user_id])
    if !user.admin?
      redirect_to new_session_path
    end
  rescue
    redirect_to new_session_path
  end
  
end
