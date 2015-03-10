class HomeController < ApplicationController
  def index
    user = User.find(session[:user_id])
    if !user.admin?
      @latest_ad = Ad.where("building_id = ? AND approved = true", cookies[:building]).order("created_at DESC").first
    end
  end
end