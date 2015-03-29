require "csv"

class Mav < ActiveRecord::Base
  belongs_to :invoice
  belongs_to :building
  belongs_to :user
  
  mount_uploader :document, DocumentUploader
  
  validates :user_id, :building_id, :invoice_id, :presence => true
  
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
    spreadsheet = open_spreadsheet(file)
    header = spreadsheet.row(1)
    (2..spreadsheet.last_row).each do |i|
      row = Hash[[header, spreadsheet.row(i)].transpose]
      puts "@@@@@@", row["CODICE MAV RID"].to_s
      mav = find_by_mav_rid(row["CODICE MAV RID"].to_i.to_s)
      if mav
        if row["STATO"] =~ /Pagato/i
          mav.status = "Pagato"
          mav.last_paid_on = Date.today
          mav.amount_paid = row["IMPORTO"]
          mav.save
        end
      end
    end
  end

  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
    when ".csv" then Roo::Csv.new(file.path, nil, :ignore)
    when ".xls" then Roo::Excel.new(file.path, nil, :ignore)
    when ".xlsx" then Roo::Excelx.new(file.path, nil, :ignore)
    else raise "Unknown file type: #{file.original_filename}"
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
end
