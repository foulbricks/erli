class AdsController < ApplicationController
  before_filter :check_admin, :only => [:administration, :approve, :approve_all]
  
  def index
    @ads = Ad.where("building_id = ? AND approved = true", cookies[:building]).order("created_at DESC").
                    paginate(:page => params[:page], :per_page => 5)
  end
  
  def new
    @ad = Ad.new
    (1..10).each do 
      @ad.ad_attachments.build
    end
  end
  
  def create
    @ad = Ad.new(ad_params)
    user = User.find(session[:user_id])
    
    if @ad.save
      flash[:notice] = "Annuncio salvato con successo"
      if user.admin?
        redirect_to administration_ads_path
      else
        redirect_to personal_ads_ads_path
      end
    else
      num = 10 - @ad.ad_attachments.size
      (1..num).each do 
        @ad.ad_attachments.build
      end
      render "new"
    end
  end
  
  def edit
    @ad = Ad.find(params[:id])
    num = 10 - @ad.ad_attachments.size
    (1..num).each do 
      @ad.ad_attachments.build
    end
  end
  
  def update
    @ad = Ad.find(params[:id])
    user = User.find(session[:user_id])
    
    if (user.admin? || @ad.user == user) && @ad.update(ad_params)
      flash[:notice] = "Annuncio modificato con successo"
      if user.admin?
        redirect_to administration_ads_path
      else
        redirect_to personal_ads_ads_path
      end
    else
      num = 10 - @ad.ad_attachments.size
      (1..num).each do 
        @ad.ad_attachments.build
      end
      render "edit"
    end
  end
  
  def destroy
    user = User.find(session[:user_id])
    @ad = Ad.find(params[:id])
    if user.admin? || @ad.user == user
      @ad.destroy
    end
    
    flash[:notice] = "Annuncio cancellato con successo"
    if user.admin?
      redirect_to administration_ads_path
    else
      redirect_to personal_ads_ads_path
    end
  end
  
  def personal_ads
    @ads = Ad.where("building_id = ? and user_id = ?", cookies[:building], session[:user_id]).order("created_at DESC").
          paginate(:page => params[:page], :per_page => 5)
  end
  
  def administration
    @ads = Ad.where("building_id = ?", cookies[:building]).order("created_at DESC").
          paginate(:page => params[:page], :per_page => 5)
  end
  
  def approve
    @ad = Ad.find(params[:id])
    @ad.update_column(:approved, true)
    redirect_to :action => "administration"
  end
  
  def approve_all
    Ad.where("building_id = ? and approved = ?", cookies[:building], false).all.each do |ad|
      ad.update_column(:approved, true)
    end
    redirect_to :action => "administration"
  end
  
  private
  
  def ad_params
    params.require(:ad).permit(:user_id, :building_id, :description, :amount, :contact, :end_date, 
        :ad_attachments_attributes => [:id, :image, :_destroy])
  end
  
end