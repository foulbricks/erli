class SetupController < ApplicationController
  
  def edit
    @setup = Setup.first || Setup.create!
  end
  
  def update
    @setup = Setup.first
    
    if @setup.update(setup_params)
      redirect_to root_path
    else
      render "setup"
    end
  end
  
  def setup_params
    params
    .require(:setup)
    .permit(:balance_expenses, :iva, :istat, :mav_expiration, :invoice_generation, :invoice_delivery, 
           :unpaid_sentence, :erli_mav_email, :erli_mav_email_active, :erli_admin_email)
  end
end