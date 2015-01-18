class ApartmentExpensesController < ApplicationController
  before_filter :check_admin, :check_building_cookie
    
  def index
    @apartments = Apartment.where(:building_id => cookies[:building]).all
  end
  
  def new
    @apartment = Apartment.find(params[:apartment_id])
    @expense = @apartment.asset_expenses.build
    @expenses = Expense.where(:kind => "Appartamento", :building_id => @apartment.building.id).all
    render :layout => false
  end
  
  def create
    @apartment = Apartment.find(params[:apartment_id])
    @expense = @apartment.asset_expenses.build(apartment_expense_params)
    
    if @expense.save
      flash[:notice] = "Spesa salvata con successo"
      render :json => {:success => true }
    else
      render :json => {:errors => @expense.errors.full_messages}
    end
  end
  
  def edit
    @apartment = Apartment.find(params[:apartment_id])
    @expense = AssetExpense.find(params[:id])
  end
  
  def update
    @apartment = Apartment.find(params[:apartment_id])
    @expense = AssetExpense.find(params[:id])
    
    if @expense.update(apartment_expense_params)
      flash[:notice] = "Spesa aggiornata con successo"
      render :json => {:success => true}
    else
      render :json => {:errors => @expense.errors.full_messages}
    end
  end
  
  def destroy
    @expense = AssetExpense.find(params[:id])
    @expense.destroy
    flash[:notice] = "Spesa cancellata con successo"
    redirect_to apartment_apartment_expenses_path
  end
  
  private
  
  def apartment_expense_params
    params.require(:asset_expense).permit(:expense_id, :amount, :asset_id, :asset_type)
  end
end