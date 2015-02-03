class InvoicesController < ApplicationController
  before_filter :check_admin, :check_building_cookie
  
  def index
    @invoices = Invoice.where(building_id: cookies[:building]).
                        paginate(:per_page => 50, :page => params[:page]).order("created_at DESC")
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
  
  def show
    
  end
  
  private
  
  def invoice_params
    params.require(:invoice).permit()
  end
end