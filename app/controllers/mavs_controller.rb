class MavsController < ApplicationController
  before_filter :check_admin, :check_building_cookie
  
  def index
    @mavs = Mav.where("building_id = ?", cookies[:building]).order("created_at DESC").all
  end
  
  def update
    @mav = Mav.find(params[:id])
    
    if @mav.update(mav_params)
      format.js { render :json => { :success => download_mav_path(@mav.id) } }
    else
      format.js { render :json => { :error => @mav.errors.full_messages.join(", ") }}
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