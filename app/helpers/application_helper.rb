module ApplicationHelper
  
  def logged_in?
    session[:user_id].present?
  end
  
  def logged_user
    if session[:user_id].present?
      User.find(session[:user_id])
    end
  end
  
  def buildings
    Building.all
  end
  
end
