class LeasesController < ApplicationController
  before_filter :check_admin, :check_building_cookie
  
  def index
    @apartments = Apartment.where(:building_id => cookies[:building]).order("name ASC").all
  end
  
  def new
    @lease = Lease.new(:apartment_id => params[:apartment_id])
    @user = @lease.users.build
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
    @user = @lease.users.where("secondary = false").first
    @apartment = @lease.apartment
    render :layout => false
  end
  
  def update
    @lease = Lease.find(params[:id])
    
    respond_to do |format|
      if @lease.update(lease_params)
        flash[:notice] = "Locazione modificata con successo"
        format.json { render :json => { :success => true } }
        format.html { render :text => "" }
      else
        format.json { render :json => {:errors => @lease.errors.full_messages} }
        format.html {
          render :text => @lease.errors.full_messages
        }
      end
    end
  end
  
  def destroy
    @lease = Lease.find(params[:id])
    @lease.destroy
    flash[:notice] = "Locazione cancellata con successo"
    redirect_to leases_path
  end
  
  def registration
    @lease = Lease.find(params[:id])
    @contracts = Contract.all
    @apartment = @lease.apartment
    render :layout => false
  end
  
  def lease_attachment
    @lease = Lease.find(params[:id])
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
  
  def delete_attachment
    @file = LeaseAttachment.find(params[:id])
    @file.destroy
    flash[:notice] = "Documente cancellato con successo"
    redirect_to leases_path
  end
  
  def close
    @lease = Lease.find(params[:id])
    @lease.update_columns(:active => false, :inactive_date => Date.today)
    @lease.users.each {|u| u.destroy }
    flash[:notice] = "Locazione chiuso con successo"
    redirect_to leases_path
  end
  
  def history
    @apartment = Apartment.find(params[:id])
    if request.post?
      @leases = []
      leases = @apartment.inactive_leases.each do |lease|
        @leases << lease if /#{params[:search]}/ =~ lease.searchable_attributes
      end
    else
      @leases = @apartment.inactive_leases
    end
  end
  
  private
  def lease_params
    params.require(:lease)
    .permit(:percentage, :contract_id, :apartment_id, :invoice_address, :start_date, :end_date, :amount,
            :payment_frequency, :deposit, :registration_date, :registration_number, :registration_agency,
            :cap, :localita, :provincia,
            :users_attributes => [:id, :first_name, :last_name, :email, :codice_fiscale],
            :lease_attachments_attributes => [:document, :lease_document])
  end
  
end