class UnpaidWarningsController < ApplicationController
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
  
  def unpaid_warning_params
    params.require(:unpaid_warning).permit()
  end
end