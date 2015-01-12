class BalanceDatesController < ApplicationController
  before_filter :check_admin, :check_building_cookie
  
  def index
    @dates = BalanceDate.where("building_id = ?", cookies[:building]).order("value DESC").all
  end
  
  def new
    @date = BalanceDate.new
  end
  
  def create
    @date = BalanceDate.new(date_params)
    
    if @date.save
      flash[:notice] = "Data conguaglio salvata con successo"
      redirect_to balance_dates_path
    else
      render "new"
    end
  end
  
  def edit
    @date = BalanceDate.find(params[:id])
  end
  
  def update
    @date = BalanceDate.find(params[:id])
    
    if @date.update(date_params)
      flash[:notice] = "Data conguaglio modificata con successo"
      redirect_to balance_dates_path
    else
      render "edit"
    end
  end
  
  def destroy
    @date = BalanceDate.find(params[:id])
    @date.destroy
    
    flash[:notice] = "Data conguaglio cancellata con successo"
    redirect_to balance_dates_path
  end
  
  private
  
  def date_params
    params.require(:balance_date).permit(:value, :building_id)
  end
end