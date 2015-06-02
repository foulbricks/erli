class HomeController < ApplicationController
  def index
    user = User.find(session[:user_id])
    if !user.admin?
      main_user = user.secondary? ? user.tenant : user
      @setup = Setup.where("building_id = ?", cookies[:building]).first
      @unpaid_mavs = Mav.where("user_id = ? AND status = 'Da Pagare' " + 
                               "AND document IS NOT NULL", main_user.id).all
      @warnings = UnpaidWarning.where("building_id = ?", cookies[:building]).order("days ASC").all
      @latest_ad = Ad.where("building_id = ? AND approved = true", cookies[:building]).order("created_at DESC").first
    else
      # if cookies[:building].present?
      #   @labels = Event.where("label IS NOT NULL or label <> '' AND building_id = ?", cookies[:building]).all.map {|e| e.label }
      # else
        @labels = Event.where("label IS NOT NULL or label <> ''").all.map {|e| e.label.split(/, ?/) }.flatten.uniq
      # end
    end
  end
end