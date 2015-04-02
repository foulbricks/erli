class BuildingExpensesController < ApplicationController
  before_filter :check_admin, :check_building_cookie
  
  def index
    @building = Building.find(params[:building_id])
    @expenses = Expense.where(:building_id => params[:building_id], :kind => "Edificio").order("created_at DESC").all
  end
  
  def new
    @building = Building.find(params[:building_id])
    @asset_expense = @building.asset_expenses.build
    @expense = Expense.find(params[:expense_id])
    render :layout => false
  end
  
  def create
    @building = Building.find(params[:building_id])
    @asset_expense = @building.asset_expenses.build(building_expense_params)
    @expense = @asset_expense.expense
  
    respond_to do |format|
      if @asset_expense.save
        flash[:notice] = "Spesa salvata con successo"
        format.json { render :json => {:success => true } }
        format.html { render :text => "success" }
      else
        format.json { render :json => {:errors => @asset_expense.errors.full_messages} }
        format.html { render :text => @asset_expense.errors.full_messages }
      end
    end
  end
  
  def edit
    @building = Building.find(params[:building_id])
    @asset_expense = AssetExpense.find(params[:id])
    @expense = Expense.find(params[:expense_id])
    render :layout => false
  end
  
  def update
    @building = Building.find(params[:building_id])
    @asset_expense = AssetExpense.find(params[:id])
    @expense = @asset_expense.expense
    
    respond_to do |format|
      if @asset_expense.update(building_expense_params)
        
        flash[:notice] = "Spesa aggiornata con successo"
        format.json { render :json => {:success => true } }
        format.html { render :text => "success" }
      else
        format.json { render :json => {:errors => @asset_expense.errors.full_messages} }
        format.html { render :text => @asset_expense.errors.full_messages }
      end
    end
  end
  
  def destroy
    @building = Building.find(params[:building_id])
    @expense = AssetExpense.find(params[:id])
    @expense.destroy
    flash[:notice] = "Spesa cancellata con successo"
    redirect_to building_building_expenses_path(@building.id)
  end
  
  def download_attachment
    @file = ExpenseAttachment.find(params[:id]).document
    send_file(@file.file.path,
      :filename => @file.file.filename,
      :type => @file.file.content_type,
      :disposition => "attachment",
      :url_based_filename => true
    )
  end
  
  def delete_attachment
    @building = Building.find(params[:building_id])
    @file = ExpenseAttachment.find(params[:id])
    @file.destroy
    flash[:notice] = "Documente cancellato con successo"
    redirect_to building_building_expenses_path(@building.id)
  end
  
  private
  
  def building_expense_params
    params.require(:asset_expense).permit(:expense_id, :amount, :asset_id, :asset_type, :start_date,
                  :end_date, :expense_attachment_attributes => [:document, :id] )
  end
end