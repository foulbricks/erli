class UnpaidEmailsController < ApplicationController
  before_filter :check_building_cookie
  before_filter :check_admin
  
  def index
    @emails = UnpaidEmail.where("building_id = ?", cookies[:building]).all
  end
  
  def new
    @email = UnpaidEmail.new
  end
  
  def create
    @email = UnpaidEmail.new(unpaid_email_params)
    
    if @email.save
      flash[:notice] = "Email non pagato salvato con successo"
      redirect_to unpaid_emails_path
    else
      render "new"
    end
  end
  
  def edit
    @email = UnpaidEmail.find(params[:id])
  end
  
  def update
    @email = UnpaidEmail.find(params[:id])
    
    if @email.update(unpaid_email_params)
      flash[:notice] = "Email non pagato aggiornato con successo"
      redirect_to unpaid_emails_path
    else
      render "edit"
    end
  end
  
  def destroy
    @email = UnpaidEmail.find(params[:id])
    @email.destroy
    
    flash[:notice] = "Email non pagato cancellato con successo"
    redirect_to unpaid_emails_path
  end
  
  private
  
  def unpaid_email_params
    params.require(:unpaid_email).permit()
  end
end