class CompaniesController < ApplicationController
  before_filter :check_admin, :clear_building
  
  def edit
    @company = Company.first || Company.new
  end
  
  def update
    @company = Company.first || Company.new(company_params)
    
    if @company.new_record? && @company.save
      flash[:notice] = "Informazione aziendali modificata con successo."
      redirect_to root_path
    elsif @company.update(company_params)
      flash[:notice] = "Informazione aziendali modificata con successo."
      redirect_to root_path
    else
      render "edit"
    end
  end
  
  private
  def company_params
    params.require(:company).permit(:id, :name, :address, :home_number, :cap, 
                                    :provincia, :localita, :partita_iva, :phone, :fax, :welcome_text, :reset_password_text)
  end
end