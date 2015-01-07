class ExpensesController < ApplicationController
  
  def index
    @expenses = Expense.all
  end
  
  def new
    @expense = Expense.new
    @tables = RepartitionTable.where(:building_id => cookies[:building]).all
  end
  
  def create
    @expense = Expense.new(expenses_params)
    @tables = RepartitionTable.where(:building_id => cookies[:building]).all
    
    if @expense.save
      flash[:notice] = "Spesa salvata con successo"
      redirect_to expenses_path
    else
      render "new"
    end
  end
  
  def edit
    @expense = Expense.find(params[:id])
    @tables = RepartitionTable.where(:building_id => cookies[:building]).all
  end
  
  def update
    @expense = Expense.find(params[:id])
    @tables = RepartitionTable.where(:building_id => cookies[:building]).all
    
    if @expense.update(expenses_params)
      flash[:notice] = "Spesa modificata con successo"
      redirect_to expenses_path
    else
      render "edit"
    end
  end
  
  def destroy
    @expense = Expense.find(params[:id])
    @expense.destroy
    
    flash[:notice] = "Spesa cancellata con successo"
    redirect_to expenses_path
  end
  
  def show
    @expense = Expense.find(params[:id])
  end
  
  private
  
  def expenses_params
    params.require(:expense).permit(:name, :kind, :add_to_invoice, :repartition_table_id, :building_id)
  end
  
end