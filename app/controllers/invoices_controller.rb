class InvoicesController < ApplicationController
  before_filter :check_admin, :except => [:download]
  before_filter :check_building_cookie, :except => [:download]
  
  def index
    @apartments = Apartment.where("building_id = ?", cookies[:building]).order("name ASC").all
    if params[:apartment_id].present?
      apartment = Apartment.find(params[:apartment_id])
      ids = apartment.leases.map(&:id)
      @invoices = Invoice.where("lease_id IN (?)", ids).
                    paginate(:per_page => 50, :page => params[:page]).order("number DESC")
    else
      @invoices = Invoice.where(building_id: cookies[:building]).
                        paginate(:per_page => 50, :page => params[:page]).order("number DESC")
    end
  end
  
  def new
    @invoice = Invoice.new
    @csvs = MavCsv.where("building_id = ? AND generated IS NOT NULL", cookies[:building]).
                   order("generated DESC").all
    (1..10).each do 
      @invoice.invoice_charges.build(:kind => "custom_expense")
    end
  end
  
  def create
    @invoice = Invoice.new(invoice_params)
    @invoice.populate(cookies[:building])

    if @invoice.save
      @invoice.post_save
      flash[:notice] = "Fattura salvata con successo"
      redirect_to invoices_path
    else
      @csvs = MavCsv.where("building_id = ? AND generated IS NOT NULL", cookies[:building]).
                     order("generated DESC").all
      render "new"
    end
  end
  
  def edit
    @invoice = Invoice.find(params[:id])
    @csvs = MavCsv.where("building_id = ? AND generated IS NOT NULL", cookies[:building]).
                   order("generated DESC").all
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
      @csvs = MavCsv.where("building_id = ? AND generated IS NOT NULL", cookies[:building]).
                     order("generated DESC").all
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
    user = User.find(session[:user_id])
    invoice = Invoice.find(params[:id])
    
    if user.admin? || (user.lease == invoice.lease)
      @file = invoice.document
      send_file(@file.file.path,
        :filename => @file.file.filename,
        :type => @file.file.content_type,
        :disposition => "attachment",
        :url_based_filename => true
      )
    else
      redirect_to root_path
    end
  end
  
  def approve
    invoice = Invoice.find(params[:id])
    invoice.toggle!(:approved)
    redirect_to invoices_path
  end
  
  private
  
  def invoice_params
    params.require(:invoice).permit(:lease_id, :building_id, :start_date, :end_date, :mav_csv_id,
      :invoice_charges_attributes => [:id, :amount, :start_date, :end_date, :kind, :asset_expense_id, :lease_id, :iva_exempt, :name])
  end
end