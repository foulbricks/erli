class BollosController < ApplicationController
  
  def index
    @bollos = BolloRange.order(:created_at).all
  end
  
  def new
    @bollo = BolloRange.new
  end
  
  def create
    if params[:from].present? && params[:to].present?
      
      begin
        range = (params[:from]..params[:to])
      rescue
        flash[:alert] = "Il intervallo non e valido"
        render "new" and return
      end
       
      @bollo, bollos_created = nil, []

      begin
        range.each do |number|
          @bollo = Bollo.new(:identifier => number, :price => params[:price])
          @bollo.save!
          bollos_created << number
        end
      rescue
        bollos_created.each {|b| b.destroy }
      end
    
      if @bollo && @bollo.valid?
        flash[:notice] = "Bollos salvati con successo"
        redirect_to bollos_path
      else
        render "new"
      end
    else
      flash[:alert] = "Inserisci un intervallo per favore"
      render "new"
    end
  end
  
  def edit
    @bollo = Bollo.find(params[:id])
  end
  
  def update
    @bollo = Bollo.find(params[:id])
    
    if @bollo.update(bollo_params)
      flash[:notice] = "Bollo modificato con successo"
      redirect_to bollos_path
    else
      render "edit"
    end
  end
  
  def destroy
    @bollo = Bollo.find(params[:id])
    @bollo.destroy
    
    flash[:notice] = "Bollo cancellato con successo"
    redirect_to bollos_path
  end
  
  private
  
  def bollo_params
    params.require(:bollo).permit(:identifier, :price, :invoice_id)
  end
  
end