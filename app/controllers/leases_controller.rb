class LeasesController < ApplicationController
  before_filter :check_admin, :check_building_cookie
  
  def index
    @apartments = Apartment.where(:building_id => cookies[:building]).order("name ASC").all
  end
  
  def new
    @lease = Lease.new(:apartment_id => params[:apartment_id])
    @contracts = Contract.all
    @apartment = Apartment.find(params[:apartment_id])
    render :layout => false
  end
  
  def create
    @lease  = Lease.new(lease_params)
    user = @lease.users.first
    user.passwd, user.passwd_confirmation = user.make_temporary_password
    user.building_id = @lease.apartment.building_id
    
    if @lease.save
      flash[:notice] = "Locazione salvata con successo"
      render :json => {:success => true }
    else
      respond_to do |format|
        format.json { render :json => {:errors => @lease.errors.full_messages} }
        format.html { render "new" }
      end
    end
  end
  
  def edit
    @lease = Lease.find(params[:id])
    @contracts = Contract.all
    @apartment = @lease.apartment
    render :layout => false
  end
  
  def update
    @lease = Lease.find(params[:id])
    
    respond_to do |format|
      if @lease.update(lease_params)
        flash[:notice] = "Locazione modificata con successo"
        format.json { render :json => { :success => true } }
        format.html { redirect_to leases_path }
      else
        format.json { render :json => {:errors => @lease.errors.full_messages} }
        format.html { render "edit" }
      end
    end
  end
  
  def registration
    @lease = Lease.find(params[:id])
    @contracts = Contract.all
    @apartment = @lease.apartment
    render :layout => false
  end
  
  def download_attachment
    @file = LeaseAttachment.find(params[:id]).document
    send_file(@file.file.path,
      :filename => @file.file.filename,
      :type => @file.file.content_type,
      :disposition => "attachment",
      :url_based_filename => true
    )
  end
  
  private
  def lease_params
    params.require(:lease)
    .permit(:percentage, :contract_id, :apartment_id, :invoice_address, :start_date, :end_date, :amount,
            :payment_frequency, :deposit, :registration_date, :registration_number, :registration_agency,
            :users_attributes => [:first_name, :last_name, :email, :codice_fiscale],
            :lease_attachments_attributes => [:document, :lease_document])
  end
  
end