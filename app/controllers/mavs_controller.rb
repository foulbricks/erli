class MavsController < ApplicationController
  before_filter :check_admin, :except => [:download]
  before_filter :check_building_cookie
  
  def index
    @mavs = Mav.joins("LEFT OUTER JOIN users ON users.id = mavs.user_id").
                joins("LEFT OUTER JOIN leases ON leases.id = users.lease_id").
                where(*get_query_array(params)).
                order("created_at DESC").
                paginate(:per_page => 50, :page => params[:page])
    
    @users = User.where("secondary = false OR secondary IS NULL AND admin = false AND building_id = ?", cookies[:building]).
                  order("first_name ASC, last_name ASC").all
    @invoices = Invoice.where("building_id = ?", cookies[:building]).order("number ASC").all
    @apartments = Apartment.where("building_id = ?", cookies[:building]).order("name ASC").all
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
    @files = MavCsv.where("building_id = ? AND generated IS NOT NULL", cookies[:building]).
                    order("created_at DESC").all
  end
  
  def generate_csv
    @mav_csv = MavCsv.create(:building_id => cookies[:building], :generated => Date.today)
    MavCsv.where("created_at < ? AND active = ?", @mav_csv.created_at, true).all.each {|csv| csv.update_attribute(:active, false) }
    invoices = Invoice.where("approved = ? AND mavs_status IS NULL", true).all
    @mav_csv.invoices << invoices
    if @mav_csv.save
      invoices.each {|i| i.update_attribute(:mav_csv_id, @mav_csv.id) }
    end
    redirect_to csvs_mavs_path, notice: "Mav Csv Generato con Successo"
  end
  
  def destroy_csv
    @mav_csv = MavCsv.find(params[:id])
    if @mav_csv.active?
      if newest = MavCsv.where("id <> ?", @mav_csv.id).order("created_at DESC").first
        newest.update_attribute(:active, true)
      end
    end
    @mav_csv.destroy
    newest.invoices.each {|i| i.update_attribute(:mav_csv_id, newest.id) } if newest
    redirect_to csvs_mavs_path, notice: "Mav Csv Cancellato con Successo"
  end
  
  def set_status_csv
    @mav_csv = MavCsv.find(params[:id])
    @mav_csv.toggle!(:uploaded)
    redirect_to csvs_mavs_path, notice: "Mav Csv Cambiato con Successo"
  end
  
  def download_csv
    @mav_csv = MavCsv.find(params[:id])
    send_data @mav_csv.generate_csv, :type => 'text/csv; charset=iso-8859-1; header=present', 
                                     :disposition => "attachment; filename=#{@mav_csv.name}.csv"
  end
  
  def download
    mav = Mav.find(params[:id])
    user = User.find(session[:user_id])
    main_user = user.secondary? ? user.tenant : user

    if user.admin? || (main_user == mav.user)
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
  
  def unpaid
    @users = User.where("secondary = false OR secondary IS NULL AND admin = false AND building_id = ?", cookies[:building]).
                  order("first_name ASC, last_name ASC").all
    @apartments = Apartment.where("building_id = ?", cookies[:building]).order("name ASC").all
    @dates  = Mav.select("DISTINCT(expiration::date), *").
                  where("expiration IS NOT NULL").order("expiration DESC").all
                  
    @mavs = Mav.joins("LEFT OUTER JOIN users ON users.id = mavs.user_id").
                joins("LEFT OUTER JOIN leases ON leases.id = users.lease_id").
                where(*get_query_array(params, true)).
                order("created_at DESC").
                paginate(:per_page => 50, :page => params[:page])
  end
  
  def report_paid
    count = Mav.import(params[:file])
    flash[:notice] = "#{count} MAV contrassegnati come pagati"
    redirect_to unpaid_mavs_path
  end
  
  def upload_batch
    count = Mav.upload_batch(params[:file])
    flash[:notice] = "Caricati #{count} file"
    redirect_to mavs_path
  end
  
  private
  
  def mav_params
    params.require(:mav).permit(:id, :document, :expiration, :mav_rid)
  end
  
  def get_query_array(params, unpaid=false)
    query = [ [ "mavs.building_id = ? AND mavs.document IS NOT NULL" ], cookies[:building] ]
    if unpaid
      query[0].push "status ~ 'Da Pagare'"
      query[0].push "expiration < ?"
      query.push Date.today
    end
    
    if params[:user].present?
      query[0].push "mavs.user_id = ?"
      query.push    params[:user]
    end
    
    if params[:invoice].present?
      query[0].push "mavs.invoice_id = ?"
      query.push    params[:invoice]
    end
    
    if params[:apartment].present?
      query[0].push "leases.apartment_id = ?"
      query.push    params[:apartment]
    end
    
    if params[:expiration].present?
      query[0].push "mavs.expiration = ?"
      query.push Date.parse(params[:expiration])
    end
    
    query[0] = query[0].join(" AND ")
    
    query
  end
end