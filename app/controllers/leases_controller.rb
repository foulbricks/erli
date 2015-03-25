class LeasesController < ApplicationController
  before_filter :check_admin, :except => [:download_attachment]
  before_filter :check_building_cookie
  
  def index
    @apartments = Apartment.where(:building_id => cookies[:building]).order("name ASC").all
  end
  
  def new
    @lease = Lease.new(:apartment_id => params[:apartment_id])
    @contracts = Contract.all
    @apartment = Apartment.find(params[:apartment_id])
    @lease.build_expenses(@apartment.building_id)
    render :layout => false
  end
  
  def create
    @lease  = Lease.new(lease_params)
    
    respond_to do |format|
      if @lease.save
        flash[:notice] = "Contratto salvato con successo"
        format.json { render :json => {:success => true } }
        format.html { render :text => "success" }
      else
        format.json { render :json => {:errors => @lease.errors.full_messages} }
        format.html { render :text => @lease.errors.full_messages }
      end
    end
  end
  
  def edit
    @lease = Lease.find(params[:id])
    @contracts = Contract.all
    @apartment = @lease.apartment
    @lease.build_expenses(@apartment.building_id)
    render :layout => false
  end
  
  def update
    @lease = Lease.find(params[:id])
    registration = @lease.registration_date
    
    respond_to do |format|
      if @lease.update(lease_params)
        if registration.blank? && @lease.registration_date.present?
          @lease.users.each { |user| user.send_signup_notification! }
        end
        flash[:notice] = "Contratto modificato con successo"
        format.json { render :json => { :success => true } }
        format.html { render :text => "success" }
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
    flash[:notice] = "Contratto cancellato con successo"
    redirect_to leases_path
  end
  
  def registration
    @lease = Lease.find(params[:id])
    @contracts = Contract.all
    @apartment = @lease.apartment
    render :layout => false
  end
  
  def tenant
    @lease = Lease.find(params[:id])
    @apartment = @lease.apartment
    @user = @lease.users.build
    render :layout => false
  end
  
  def lease_attachment
    @lease = Lease.find(params[:id])
    @apartment = @lease.apartment
    render :layout => false
  end
  
  def download_attachment
    user = User.find(session[:user_id])
    attachment = LeaseAttachment.find(params[:id])
    
    if user.admin? || (user.lease == attachment.lease and attachment.lease_document?)
      @file = attachment.document
    
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
  
  def delete_attachment
    @file = LeaseAttachment.find(params[:id])
    @file.destroy
    flash[:notice] = "Documento cancellato con successo"
    redirect_to leases_path
  end
  
  def close
    @lease = Lease.find(params[:id])
    @lease.update_columns(:active => false, :inactive_date => Date.today)
    @lease.cache_users
    @lease.users.each {|u| u.destroy }
    flash[:notice] = "Contratto chiuso con successo"
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
  
  def confirm
    @lease = Lease.find(params[:id])
    @lease.update_column(:confirmed, true)
    flash[:notice] = "Contratto confermato con successo"
    redirect_to leases_path
  end
  
  private
  def lease_params
    params.require(:lease)
    .permit(:percentage, :contract_id, :apartment_id, :invoice_address, :start_date, :end_date, :amount,
            :payment_frequency, :deposit, :registration_date, :registration_number, :registration_agency,
            :cap, :localita, :provincia, :fully_charged,
            :users_attributes => [:id, :first_name, :last_name, :email, :codice_fiscale, :secondary, 
              :percentage, :partita_iva, :building_id],
            :lease_attachments_attributes => [:document, :lease_document],
            :asset_expenses_attributes => [:id, :expense_id, :amount, :asset_id, :asset_type])
  end
  
end