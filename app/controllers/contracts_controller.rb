class ContractsController < ApplicationController
  
  def index
    @contracts = Contract.all
  end
  
  def new
    @contract = Contract.new
  end
  
  def create
    @contract = Contract.new(contract_params)
    
    if @contract.save
      flash[:notice] = "Tipo di contratto salvato con successo"
      redirect_to contracts_path
    else
      render "new"
    end
  end
  
  def edit
    @contract = Contract.find(params[:id])
  end
  
  def update
    @contract = Contract.find(params[:id])
    
    if @contract.update(contract_params)
      flash[:notice] = "Tipo di contratto modificato con successo"
      redirect_to contracts_path
    else
      render "edit"
    end
  end
  
  def destroy
    @contract = Contract.find(params[:id])
    @contract.destroy
    
    flash[:notice] = "Tipo di contratto cancellato con successo"
    redirect_to contracts_path
  end
  
  private
  def contract_params
    params.require(:contract).permit(:name, :istat)
  end
  
end