class BuildingsController < ApplicationController
  
  def index
    @buildings = Building.all
  end
  
  def new
    @building = Building.new
  end
  
  def create
    @building = Building.new(building_params)
    
    if @building.save
      flash[:notice] = "Building successfully saved."
      redirect_to buildings_path
    else
      render "new"
    end
  end
  
  def edit
    @building = Building.find(params[:id])
  end
  
  def update
    @building = Building.find(params[:id])
    
    if @building.update(building_params)
      flash[:notice] = "Building successfully updated."
      redirect_to buildings_path
    else
      render "edit"
    end
  end
  
  def destroy
    @building = Building.find(params[:id])
    @building.destroy
    
    flash[:notice] = "Building successfully destroyed"
    redirect_to buildings_path
  end
  
  def set_workspace
    cookies[:building] = params[:building]
    redirect_to :back
  end
  
  private
  def building_params
    params.require(:building).permit(:name, :address)
  end
  
end