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
  
    respond_to do |format|
      if @expense.save
        flash[:notice] = "Spesa salvata con successo"
        format.json { render :json => {:success => true } }
        format.html { render :text => "success" }
      else
        format.json { render :json => {:errors => @expense.errors.full_messages} }
        format.html { render :text => @expense.errors.full_messages }
      end
    end
  end
  
  def edit
    @apartment = Apartment.find(params[:apartment_id])
    @expense = AssetExpense.find(params[:id])
    @expenses = Expense.where(:kind => "Appartamento", :building_id => @apartment.building.id).all
    render :layout => false
  end
  
  def update
    @apartment = Apartment.find(params[:apartment_id])
    @expense = AssetExpense.find(params[:id])
    
    respond_to do |format|
      if @expense.update(apartment_expense_params)
        
        flash[:notice] = "Spesa aggiornata con successo"
        format.json { render :json => {:success => true } }
        format.html { render :text => "success" }
      else
        format.json { render :json => {:errors => @expense.errors.full_messages} }
        format.html { render :text => @expense.errors.full_messages }
      end
    end
  end
  
  def destroy
    @expense = AssetExpense.find(params[:id])
    @expense.destroy
    flash[:notice] = "Spesa cancellata con successo"
    redirect_to apartment_expenses_path
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
    @file = ExpenseAttachment.find(params[:id])
    @file.destroy
    flash[:notice] = "Documente cancellato con successo"
    redirect_to apartment_expenses_path
  end
  
  private
  
  def apartment_expense_params
    params.require(:asset_expense).permit(:expense_id, :amount, :asset_id, :asset_type,
                  :expense_attachment_attributes => [:document, :id] )
  end
end