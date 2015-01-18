class BuildingExpensesController < ApplicationController
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
  
  def building_expense_params
    params.require(:building_expense).permit()
  end
end