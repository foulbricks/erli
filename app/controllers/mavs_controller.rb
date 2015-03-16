class MavsController < ApplicationController
  before_filter :check_admin, :check_building_cookie
  
  def index
    @mavs = Mav.where("building_id = ?", cookies[:building]).order("created_at DESC").all
    @users = User.where("secondary = false AND admin = false AND building_id = ?", cookies[:building]).all
    @invoices = Invoice.where("building_id = ?", cookies[:building]).all
    @apartments = Apartment.where("building_id = ?", cookies[:building]).all
  end
  
  def edit
    @mav = Mav.find(params[:id])
    @user = @mav.user
    render :template => "mavs/mav_upload", :layout => false
  end
  
  def update
    @mav = Mav.find(params[:id])
    
    respond_to do |format|
      if @mav.update(mav_params)
        format.js { render :json => { :success => download_mav_path(@mav.id) } }
        format.html { render :text => "success=" + [@mav.id, download_mav_path(@mav.id)].to_s }
      else
        format.js { render :json => { :error => @mav.errors.full_messages.join(", ") }}
        format.html { render :text => @mav.errors.full_messages }
      end
    end
  end
  
  def csvs
    @files = MavCsv.where("building_id = ?", cookies[:building]).order("created_at DESC").all
  end
  
  def generate_csv
    @mav_csv = MavCsv.find(params[:id])
    filename = @mav_csv.created_at.strftime("%d-%m-%Y")
    send_data @mav_csv.generate_csv, :type => 'text/csv; charset=iso-8859-1; header=present', 
                                     :disposition => "attachment; filename=#{filename}.csv"
  end
  
  def download
    mav = Mav.find(params[:id])
    user = User.find(session[:user_id])

    if user.admin? || (user.lease == mav.lease)
      @file = mav.document
    
      send_file(@file.file.path,
        :filename => @file.file.filename,
        :type => @file.file.content_type,
        :disposition => "attachment",
        :url_based_filename => true
      )
    else
      redirect_to root_path
    end
  end
  
  private
  
  def mav_params
    params.require(:mav).permit(:id, :document)
  end
end