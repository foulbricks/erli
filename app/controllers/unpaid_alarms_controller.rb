class UnpaidAlarmsController < ApplicationController
  before_filter :check_building_cookie
  before_filter :check_admin
  
  def index
    
  end
  
  def new
    
  end
  
  def create
    
  end
  
  def edit
    
  end
  
  def update
    
  end
  
  def destroy
    
  end
  
  private
  
  def unpaid_alarm_params
    params.require(:unpaid_alarm).permit()
  end
end