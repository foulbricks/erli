class InvoicesController < ApplicationController
  before_filter :check_admin
  before_filter :check_building_cookie, :except => [:download]
  
  def index
    if request.post?
      if params[:apartment_id].present?
        apartment = Apartment.find(params[:apartment_id])
        ids = apartment.leases.map(&:id)
        @invoices = Invoice.where("lease_id IN (?)", ids).
                      paginate(:per_page => 50, :page => params[:page]).order("number DESC")
      else
        @invoices = Invoice.where(building_id: cookies[:building]).
                          paginate(:per_page => 50, :page => params[:page]).order("number DESC")
      end
    else
      @invoices = Invoice.where(building_id: cookies[:building]).
                        paginate(:per_page => 50, :page => params[:page]).order("number DESC")
    end
  end
  
  def new
    @invoice = Invoice.new
    (1..10).each do 
      @invoice.invoice_charges.build(:kind => "custom_expense")
    end
  end
  
  def create
    @invoice = Invoice.new(invoice_params)
    
    if @invoice.valid?
      @invoice.start_date = Date.today.at_beginning_of_month
      @invoice.end_date = Date.today.end_of_month
      @invoice.building_id = cookies[:building]
      @invoice.number = Invoice.get_invoice_number(@invoice.lease)
      
      @invoice.invoice_charges.each do |ic|
        ic.start_date = Date.today.at_beginning_of_month
        ic.end_date = Date.today.end_of_month
        ic.lease_id = @invoice.lease_id
      end
      
      @invoice.temporary_bollo = Invoice.get_available_bollo(@invoice)
      
      temp = Invoice.tempfile(Invoice.render_pdf(@invoice.lease, @invoice, Date.today))
      @invoice.document = File.open temp.path
      temp.unlink
    end
    
    if @invoice.save
      @invoice.temporary_bollo.update_column(:invoice_id, @invoice.id) if @invoice.temporary_bollo
      flash[:notice] = "Fattura salvata con successo"
      redirect_to invoices_path
    else
      render "new"
    end
  end
  
  def edit
    @invoice = Invoice.find(params[:id])
  end
  
  def update
    @invoice = Invoice.find(params[:id])
    
    if @invoice.update(invoice_params)
      temp = Invoice.tempfile(Invoice.render_pdf(@invoice.lease, @invoice, Date.today))
      @invoice.document = File.open temp.path
      temp.unlink
      @invoice.save
      flash[:notice] = "Fattura modificata con successo"
      redirect_to invoices_path
    else
      render "edit"
    end
  end
  
  def destroy
    invoice = Invoice.find(params[:id])
    invoice.destroy
    flash[:notice] = "Fattura cancellata con successo"
    redirect_to invoices_path
  end
  
  def generate
    begin
      date = Date.parse(params[:date])
      Invoice.generate(cookies[:building], date)

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
  
  def approve
    invoice = Invoice.find(params[:id])
    invoice.toggle!(:approved)
    redirect_to invoices_path
  end
  
  private
  
  def invoice_params
    params.require(:invoice).permit(:lease_id, :building_id, :start_date, :end_date,
      :invoice_charges_attributes => [:id, :amount, :start_date, :end_date, :kind, :asset_expense_id, :lease_id, :iva_exempt, :name])
  end
end