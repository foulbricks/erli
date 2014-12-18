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
    @building = Building.fin(params[:id])
  end
  
  def update
    
  end
  
  def destroy
    
  end
  
  private
  def building_params
    params.require(:building).permit(:name, :address)
  end
  
end