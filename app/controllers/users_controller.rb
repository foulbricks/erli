class UsersController < ApplicationController
  before_filter :clear_building, :except => [:contract, :invoices, :mavs, :forgot_password, :profile]
  before_filter :check_admin, :except => [:forgot_password, :reset_password, :activate, :contract, :invoices, :mavs, :profile]
  skip_before_filter :authorize, :only => [:forgot_password, :reset_password, :activate]
  
  def index
    @users = User.where(["admin = ?", true]).order("email DESC").all
  end
  
  def new
    @user = User.new
  end
  
  def create
    @user = User.new(user_params)
    @user.admin = true
    
    respond_to do |format|
      if @user.save
        format.html { 
          flash[:notice] = "User successfully saved"
          redirect_to users_path
        }
      else
        format.html {
          render "new"
        }
      end
    end
  end
  
  def edit
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])
    
    respond_to do |format|
      if @user.update_attributes(user_params)
        format.html {
          flash[:notice] = "User successfully updated"
          redirect_to users_path
        }
      else
        format.html {
          render "edit"
        }
      end
    end
  end
  
  def destroy
    @user = User.find(params[:id])
    if User.count > 1
      @user.destroy
      flash[:notice] = "User successfully deleted"
    else
      flash[:alert] = "Could not delete administrator because there would be none left!"
    end
    
    respond_to do |format|
      format.html {
        redirect_to users_path
      }
    end
  end 
  
  def forgot_password
    if request.post?
      user = User.find_by_email(params[:email])
      if user
        flash.now[:notice] = "Grazie. Una e-mail e stata inviata al proprio account di posta elettronica"
        user.forgot_password!
      else
        flash.now[:alert] = "Email non e stato trovato"
      end
    end
  end
  
  def reset_password
    @user = User.find_by_pw_code(params[:pw_code])
    if @user && @user.within_pw_reset_time?
      if request.post?
        params[:user] ||= {}
        if params[:user][:passwd] == params[:user][:passwd_confirmation] && params[:user][:passwd].present?
          @user.reset_pw!(params[:user][:passwd])
          @user.save
          flash[:notice] = "Grazie. La password ha stata modificata. Si prega acceda il sitio con la nuova password"
          redirect_to :controller => "sessions", :action => "new"
        else
          flash.now[:alert] = "Password non coincide con la conferma"
          render "reset_password"
        end
      else
        render "reset_password"
      end
    else
      flash[:alert] = "Il tempo per attivare il tuo account e scaduto. Si prega di modificare entro tre giorni"
      redirect_to :action => "forgot_password"
    end
  end
  
  def activate
    user = User.find_by_activation_code(params[:activation_code])
    if user
      if user.within_activation_time?
        user.activation_code = nil
        user.activation_code_set_at = nil
        user.active = true
        user.building_id = user.lease.apartment.building.id
        user.make_pw_reset_code!
        user.save(:validate => false)
        flash[:notice] = "Grazie. Il tuo account e stato attivato. Si prega di creare la password"
        redirect_to :action => "reset_password", :pw_code => user.pw_code
      else
        user.send_signup_notification!
        flash[:alert] = "Il tempo per attivare il tuo account e scaduto. Un'altra email e stata inviata. " +
                        "Si prega di attivare entro tre giorni"
        redirect_to root_path
      end
    else
      flash[:alert] = "Avete gia attivato il tuo account. Chiedere per reimpostare la password se hai dimenticato la password"
      redirect_to root_path
    end
  end
  
  def contract
    @user = User.find(session[:user_id])
    @contracts = LeaseAttachment.where("lease_id = ? AND lease_document = true", @user.lease_id).all
  end
  
  def invoices
    
  end
  
  def mavs
    
  end
  
  def profile
    @user = User.find(session[:user_id])
    if request.post?
      params[:user] ||= {}
      @user.email = params[:user][:email]
      if @user.admin?
        @user.first_name = params[:user][:first_name]
        @user.last_name = params[:user][:last_name]
      end
      if @user.valid?
        @user.save
        flash[:notice] = "Profilo salvato con successo"
        redirect_to root_path
      else
        render "profile"
      end
    end
  end
  
  private
  
  def user_params
    params.require(:user).permit(:first_name, :last_name, :passwd, :email, :passwd_confirmation, :active)
  end
      
end