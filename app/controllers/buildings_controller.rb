class BuildingsController < ApplicationController
  before_filter :check_admin
  before_filter :clear_building, :except => :set_workspace
  
  def index
    @buildings = Building.all
  end
  
  def new
    @building = Building.new
  end
  
  def create
    @building = Building.new(building_params)
    
    if @building.save
      flash[:notice] = "Edificio salvato con successo"
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
      flash[:notice] = "Edificio modificato con successo."
      redirect_to buildings_path
    else
      render "edit"
    end
  end
  
  def destroy
    @building = Building.find(params[:id])
    @building.destroy
    
    flash[:notice] = "Edificio cancellato con successo."
    redirect_to buildings_path
  end
  
  def set_workspace
    cookies[:building] = {value: params[:building], expires: Time.now + 3600}
    if request.referer.present? && controller_name != "buildings"
      redirect_to :back
    else
      redirect_to root_path
    end
  end
  
  private
  def building_params
    params.require(:building).permit(:name, :address)
  end
  
end