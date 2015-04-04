require "csv"
require 'zip'

class Mav < ActiveRecord::Base
  belongs_to :invoice
  belongs_to :building
  belongs_to :user
  
  mount_uploader :document, DocumentUploader
  
  validates :user_id, :building_id, :invoice_id, :presence => true
  
  MAV_PROCESSING_PATH = File.join(Rails.root, "public", "mavprocessing")
  
  def amount
    ((invoice.total * user.real_percentage / 100) * 100).round / 100.0
  end
  
  def expiration_value_it
    expiration ? expiration.strftime("%d-%m-%Y") : nil
  end
  
  def days_since_expired
    (Date.today - expiration).to_i
  end
  
  def self.import(file)
    count = 0
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      mav = find_by_mav_rid(row["CODICE MAV RID"].to_i.to_s)
      if mav
        if row["STATO"] =~ /Pagato/i
          mav.status = "Pagato"
          mav.last_paid_on = Date.today
          mav.amount_paid = row["IMPORTO"]
          mav.save
          count += 1
        end
      end
    end
    count
  end
  
  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
    when ".csv" then Roo::Csv.new(file.path, nil, :ignore)
    when ".xls" then Roo::Excel.new(file.path, nil, :ignore)
    when ".xlsx" then Roo::Excelx.new(file.path, nil, :ignore)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end
  
  def self.upload_batch(file)
    count = 0
    if File.extname(file.original_filename) == ".zip"
      unzip(file)
      system("bash /home/webapps/erli/shared/fn.sh") if Rails.env.production?
      
      Dir.glob(File.join(MAV_PROCESSING_PATH, "*.pdf")) do |file_path|
        name = File.basename(file_path).gsub(/\.pdf$/, "")
        codice, mavid, due_date = name.split("_")
        
        if mavid && due_date && codice
          user = User.find_by_codice_fiscale(codice)
          begin; expiration = Date.parse(due_date); rescue; end
          
          assign_mav_document(user, expiration, mavid, count, file_path) if user && expiration
        end
        File.delete(file_path)
      end
    end
    count
  end
  
  def self.assign_mav_document(user, expiration, mavid, count, file_path)
    mav = Mav.where("user_id = ? AND expiration = ?", user.id, expiration).first
    if mav
      mav.mav_rid = mavid
      File.open(file_path, "rb") do |file|
        mav.document = file
      end
      mav.save
      count += 1
    end
    count
  end

  def self.unzip(file)
    Zip::File.open(file.path) do |zip_file|
      zip_file.each do |entry|
        begin
          entry.extract(File.join(MAV_PROCESSING_PATH, entry.name.gsub(/\s+/, "_")))
        rescue
        end
      end
    end
  end
  
  def self.calculate_expiration(setup, invoice)
    if setup && setup.mav_expiration.present?
      expire = invoice.created_at.change(:day => setup.mav_expiration)
    else
      expire = invoice.created_at.end_of_month
    end
    expire = expire.next_month if expire <= invoice.created_at
    expire
  end
  
  # File.open(file_path, "rb") do |file|
  #   reader = PDF::Reader.new(file)
  #
  #   page = reader.pages[0]
  #   text = page.text
  #   text =~ /codice debitore\s*\n(\w+)\s+/im
  #   codice = $1
  #   text =~ /scadenza\s*\n\s*(\d+\/\d+\/\d+)/im
  #   due_date = $1
  #   text =~ /(\d+)\s*\n\s*timbro/im
  #   mav_id = $1
  #
  #   if mav_id && due_date && codice
  #     user = User.find_by_codice_fiscale(codice)
  #     begin
  #       expiration = Date.parse(due_date)
  #     rescue
  #     end
  #
  #     if user && expiration
  #       mav = Mav.where("user_id = ? AND expiration = ?", user.id, expiration).first
  #       if mav
  #         mav.mav_rid = mav_id
  #         mav.document = file
  #         mav.save
  #         count += 1
  #       end
  #     end
  #   end
  # end
  # File.delete(file_path)
  
end
