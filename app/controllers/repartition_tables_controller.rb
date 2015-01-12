class RepartitionTablesController < ApplicationController
  before_filter :check_admin, :check_building_cookie
  
  def index
    @tables = RepartitionTable.where(:building_id => cookies[:building]).all
  end
  
  def new
    @table = RepartitionTable.build(cookies[:building])
  end
  
  def edit
    @table = RepartitionTable.find(params[:id])
  end
  
  def create
    @table = RepartitionTable.new(repartition_table_params)
    
    if @table.save
      flash[:notice] = "Tavolo di ripartizione salvata con successo"
      redirect_to repartition_tables_path
    else
      render "new"
    end
  end
  
  def update
    @table = RepartitionTable.find(params[:id])
    
    if @table.update(repartition_table_params)
      flash[:notice] = "Tavolo di ripartizone modificata con successo"
      redirect_to repartition_tables_path
    else
      render "edit"
    end
  end
  
  def destroy
    @table = RepartitionTable.find(params[:id])
    @table.destroy
    
    flash[:notice] = "Tavolo di ripartizione cancellata con successo"
    redirect_to repartition_tables_path
  end
  
  private
  
  def repartition_table_params
    params.require(:repartition_table).permit(:name, :building_id, 
                  :apartment_repartition_tables_attributes => [:id, :apartment_id, :percentage, :floor, :name])
  end
end