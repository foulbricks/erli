class CompaniesController < ApplicationController
  before_filter :check_admin, :clear_building
  
  def edit
    @company = Company.first || Company.new
  end
  
  def update
    @company = Company.first || Company.new(company_params)
    
    if @company.new_record? && @company.save
      if request.referer =~ /general-parameters/
        flash[:notice] = "Parametri generale salvati con successo."
      else
        flash[:notice] = "Informazione aziendali salvata con successo."
      end
      redirect_to root_path
    elsif @company.update(company_params)
      if request.referer =~ /general-parameters/
        flash[:notice] = "Parametri generale modificati con successo."
      else
        flash[:notice] = "Informazione aziendali modificata con successo."
      end
      redirect_to root_path
    else
      if request.referer =~ /general-parameters/
        render "general_parameters"
      else
        render "edit"
      end
    end
  end
  
  def general_parameters
    @company = Company.first || Company.new
  end
  
  private
  def company_params
    params.require(:company).permit(:id, :name, :address, :home_number, :cap, 
                                    :provincia, :localita, :partita_iva, :phone, :fax, 
                                    :welcome_text, :reset_password_text, :iban, :email, :iva, :istat, 
                                    :words_iva_exempt, :codice_fiscale)
  end
end