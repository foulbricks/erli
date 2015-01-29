class InvoicesController < ApplicationController
  before_filter :check_admin, :check_building_cookie
  
  def index
    respond_to do |format|
      format.pdf do
        render  :pdf => "test.pdf",
                :template => "layouts/invoice.html.erb"
      end
    end
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