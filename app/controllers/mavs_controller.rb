class MavsController < ApplicationController
  before_filter :check_admin, :check_building_cookie
  
  def index
    @mavs = Mav.where("building_id = ?", cookies[:building]).order("created_at DESC").all
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
end