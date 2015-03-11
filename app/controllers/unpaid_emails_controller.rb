class UnpaidEmailsController < ApplicationController
  before_filter :check_building_cookie
  before_filter :check_admin
  
  def index
    @emails = UnpaidEmail.where("building_id = ?", cookies[:building]).all
  end
  
  def new
    @email = UnpaidEmail.new
    (1..5).each do 
      @email.unpaid_email_attachments.build
    end
  end
  
  def create
    @email = UnpaidEmail.new(unpaid_email_params)
    
    if @email.save
      flash[:notice] = "Email non pagato salvato con successo"
      redirect_to unpaid_emails_path
    else
      num = 5 - @email.unpaid_email_attachments.size
      (1..num).each do 
        @email.unpaid_email_attachments.build
      end
      render "new"
    end
  end
  
  def edit
    @email = UnpaidEmail.find(params[:id])
    num = 5 - @email.unpaid_email_attachments.size
    (1..num).each do 
      @email.unpaid_email_attachments.build
    end
  end
  
  def update
    @email = UnpaidEmail.find(params[:id])
    
    if @email.update(unpaid_email_params)
      flash[:notice] = "Email non pagato aggiornato con successo"
      redirect_to unpaid_emails_path
    else
      num = 5 - @email.unpaid_email_attachments.size
      (1..num).each do 
        @email.unpaid_email_attachments.build
      end
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
    params.require(:unpaid_email).permit(:body, :days, :frequency, :building_id,
                                         :unpaid_email_attachments => [:id, :document, :_destroy])
  end
end