class UnpaidWarningsController < ApplicationController
  before_filter :check_building_cookie
  before_filter :check_admin
  
  def index
    @warnings = UnpaidWarning.where("building_id = ?", cookies[:building]).all
  end
  
  def new
    @warning = UnpaidWarning.new
  end
  
  def create
    @warning = UnpaidWarning.new(unpaid_warning_params)
    
    if @warning.save
      flash[:notice] = "Avvertimento non pagato salvato con successo"
      redirect_to unpaid_warnings_path
    else
      render "new"
    end
  end
  
  def edit
    @warning = UnpaidWarning.find(params[:id])
  end
  
  def update
    @warning = UnpaidWarning.find(params[:id])
    
    if @warning.update(unpaid_warning_params)
      flash[:notice] = "Avvertimento non pagato aggiornato con successo"
      redirect_to unpaid_warnings_path
    else
      render "edit"
    end
  end
  
  def destroy
    @warning = UnpaidWarning.find(params[:id])
    @warning.destroy
    
    flash[:notice] = "Avvertimento non pagato cancellato con successo"
    redirect_to unpaid_warnings_path
  end
  
  private
  
  def unpaid_alarm_params
    params.require(:unpaid_alarm).permit(:text, :days, :background, :flashing, :building_id)
  end
end