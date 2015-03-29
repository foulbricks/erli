class TenantsController < ApplicationController
  before_filter :check_admin, :check_building_cookie
  
  def new
    @lease = Lease.find(params[:lease_id])
    @user = @lease.users.build(:secondary => true)
    render :layout => false
  end
  
  def create
    @lease = Lease.find(params[:lease_id])
    @user = User.new(user_params)
    @user.lease_id = @lease.id
    @user.tenant_id = @lease.users.where(:secondary => false).first.id
    @user.secondary = true
    @user.passwd = @user.passwd_confirmation = @user.make_temporary_password
    
    respond_to do |format|
      if @user.save
        @user.send_signup_notification! if @user.lease.registration_date.present?
        flash[:notice] = "Utente salvato con successo"
        format.json { render :json => {:success => true } }
        format.html { render :text => "success" }
      else
        format.json { render :json => {:errors => @user.errors.full_messages} }
        format.html { render :text => @user.errors.full_messages }
      end
    end
  end
  
  def edit
    @lease = Lease.find(params[:lease_id])
    @user = User.find(params[:id])
    render :layout => false
  end
  
  def update
    @lease = Lease.find(params[:lease_id])
    @user = User.find(params[:id])
    
    respond_to do |format|
      if @user.update(user_params)
        flash[:notice] = "Utente modificato con successo"
        format.json { render :json => { :success => true } }
        format.html { render :text => "success" }
      else
        format.json { render :json => {:errors => @user.errors.full_messages} }
        format.html {
          render :text => @user.errors.full_messages
        }
      end
    end
  end
  
  def destroy
    @lease = Lease.find(params[:lease_id])
    @user = User.find(params[:id])
    @user.destroy
    flash[:notice] = "Utente cancellato con successo"
    redirect_to leases_path
  end
  
  private
  
  def user_params
    params.require(:user).permit(:id, :first_name, :last_name, :email, :codice_fiscale, :secondary,
                                 :percentage, :partita_iva, :building_id)
  end
end