class ExpensesController < ApplicationController
  
  def index
    @expenses = Expense.all
  end
  
  def new
    @expense = Expense.new
  end
  
  def create
    @expense = Expense.new(expenses_params)
    
    if @expense.save
      flash[:notice] = "Spesa salvata con successo"
      redirect_to expenses_path
    else
      render "new"
    end
  end
  
  def edit
    @expense = Expense.find(params[:id])
  end
  
  def update
    @expense = Expense.find(params[:id])
    
    if @expense.update(expenses_params)
      flash[:notice] = "Spesa modificata con successo"
      redirect_to expenses_path
    else
      render "edit"
    end
  end
  
  def delete
    @expense = Expense.find(params[:id])
    @expense.destroy
    
    flash[:notice] = "Spesa soppressa con successo"
    redirect_to expenses_path
  end
  
  def show
    @expense = Expense.find(params[:id])
  end
  
  private
  
  def expenses_params
    params.require(:expense).permit(:name, :kind, :add_to_invoice)
  end
  
end