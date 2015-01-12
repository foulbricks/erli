class SetupController < ApplicationController
  before_filter :check_admin, :check_building_cookie
  
  def edit
    @setup = Setup.where(:building_id => cookies[:building]).first || Setup.create!(:building_id => cookies[:building])
  end
  
  def update
    @setup = Setup.where(:building_id => cookies[:building]).first
    
    if @setup.update(setup_params)
      redirect_to root_path
    else
      render "edit"
    end
  end
  
  def setup_params
    params
    .require(:setup)
    .permit(:balance_expenses, :iva, :istat, :mav_expiration, :invoice_generation, :invoice_delivery, 
           :unpaid_sentence, :erli_mav_email, :erli_mav_email_active, :erli_admin_email)
  end
end