class ApartmentsController < ApplicationController
  before_filter :check_admin
  before_filter :check_building_cookie, :except => [:tenants]
  
  def index
    @apartments = Apartment.where(:building_id => cookies[:building]).order(:name).all
  end
  
  def new
    @apartment = Apartment.new
  end
  
  def edit
    @apartment = Apartment.find(params[:id])
  end
  
  def create
    @apartment = Apartment.new(apartment_params)
    
    if @apartment.save
      flash[:notice] = "Appartamento salvato con successo"
      redirect_to apartments_path
    else
      render "new"
    end
  end
  
  def update
    @apartment = Apartment.find(params[:id])
    
    if @apartment.update(apartment_params)
      flash[:notice] = "Appartamento modificato con successo"
      redirect_to apartments_path
    else
      render "edit"
    end
  end
  
  def destroy
    @apartment = Apartment.find(params[:id])
    @apartment.destroy
    
    flash[:notice] = "Appartamento cancellato con successo"
    redirect_to apartments_path
  end
  
  def tenants
    @apartment = Apartment.find(params[:id])
    lease = @apartment.active_leases.first
    if lease
      render :json => lease.users.map {|u| {:id => u.id, :name => u.name }}
    else
      render :json => []
    end
  end
  
  private
  def apartment_params
    params.require(:apartment).permit(:name, :building_id, :rooms, :floor, :dimension)
  end
end