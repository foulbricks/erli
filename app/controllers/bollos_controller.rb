class BollosController < ApplicationController
  
  def index
    @ranges = BolloRange.order("created_at DESC").all
  end
  
  def new
    @range = BolloRange.new
  end
  
  def create
    @range = BolloRange.new(bollo_range_params)
    
    if @range.save
      (@range.from..@range.to).each do |number|
        @bollo = Bollo.new(:identifier => number, :price => @range.price, :bollo_range_id => @range.id)
        @bollo.save
      end
      flash[:success] = "Bollos salvati con successo"
      redirect_to bollo_ranges_path
    else
      render "new"
    end
  end
  
  def edit
    @range = BolloRange.find(params[:id])
  end
  
  def update
    @range = BolloRange.find(params[:id])
    
    if @range.update(bollo_range_params)
      @range.bollos.each {|b| b.destroy }
      (@range.from..@range.to).each do |number|
        @bollo = Bollo.new(:identifier => number, :price => @range.price, :bollo_range_id => @range.id)
        @bollo.save
      end
      
      flash[:notice] = "Bollos modificate con successo"
      redirect_to bollo_ranges_path
    else
      render "edit"
    end
  end
  
  def destroy
    @range = BolloRange.find(params[:id])
    @range.bollos.where("invoice_id IS NULL").all.each {|b| b.destroy }
    @range.destroy
    
    flash[:notice] = "Bollos elliminate con successo"
    redirect_to bollo_ranges_path
  end
  
  def edit_bollo
    @bollo = Bollo.find(params[:id])
  end
  
  def update_bollo
    @bollo = Bollo.find(params[:id])
    
    if @bollo.update(bollo_params)
      flash[:notice] = "Bollo modificato con successo"
      redirect_to bollo_ranges_path
    else
      render "edit_bollo"
    end
  end
  
  def destroy_bollo
    @bollo = Bollo.find(params[:id])
    
    if @bollo.destroy
      flash[:notice] = "Bollo cancellato con successo"
    else
      flash[:alert] = "Bollo non puo essere eliminato perche ha gia una fattura!"
    end
    redirect_to bollo_ranges_path
  end
  
  private
  
  def bollo_params
    params.require(:bollo).permit(:identifier, :price)
  end
  
  def bollo_range_params
    params.require(:bollo_range).permit(:from, :to, :price)
  end
  
end