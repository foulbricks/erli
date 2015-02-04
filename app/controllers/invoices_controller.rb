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
  
  def generate
    begin
      date = Date.parse(params[:date])
      Invoice.generate(cookies[:building], date)
    rescue => e
      flash[:alert] = e.message
    end
    redirect_to invoices_path
  end
  
  def download
    @file = Invoice.find(params[:id]).document
    send_file(@file.file.path,
      :filename => @file.file.filename,
      :type => @file.file.content_type,
      :disposition => "attachment",
      :url_based_filename => true
    )
  end
  
  private
  
  def invoice_params
    params.require(:invoice).permit()
  end
end