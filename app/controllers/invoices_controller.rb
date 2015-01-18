class InvoicesController < ApplicationController
  before_filter :check_admin, :check_building_cookie
  
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
  
  def invoice_params
    params.require(:invoice).permit()
  end
end