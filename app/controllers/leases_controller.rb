class LeasesController < ApplicationController
  before_filter :check_admin, :check_building_cookie
  
  def index
    @apartments = Apartment.where(:building_id => cookies[:building]).all
    @lease = Lease.new
    @contracts = Contract.all
  end
  
  def new
    @lease = Lease.new(:apartment_id => params[:apartment])
    @contracts = Contract.all
    render :layout => false
  end
  
  def create
    
  end
  
  def edit
    
  end
  
  def update
    
  end
  
  def destroy
    
  end
  
  private
  def lease_params
    params.require(:lease).permit()
  end
  
end