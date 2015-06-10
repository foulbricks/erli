require "csv"

class MavCsv < ActiveRecord::Base
  has_and_belongs_to_many :invoices
  belongs_to :building
  
  validates :building_id, :presence => true
  
  before_destroy do
    Invoice.where("mav_csv_id = ?", id).all.each {|i| i.update_attribute(:mav_csv_id, nil) }
    invoices.clear
  end
  
  def value_it_locale
    generated.strftime("%d-%m-%Y")
  end
  
  def name
    if active?
      "#{building.name}_#{created_at.strftime('%d-%m-%Y_%H_%M_%S')}"
    else
      "INVALID_#{building.name}_#{created_at.strftime('%d-%m-%Y_%H_%M_%S')}"
    end
  end
  
  def status
    if !uploaded?
      "Appena Generato"
    else
      "Scaricato"
    end
  end
  
  def generate_csv
    CSV.generate(col_sep: ";", :quote_char => "$") do |csv|
      csv << ["IMPORTO IN CENTESIMI", "CAUSALE PAGAMENTO", "SCADENZA PAGAMENTO", "COD DEBITORE",
              "CF o PIVA", "COGNOME O RAGIONE SOCIALE", "INDIRIZZO DEBITORE", "CAP DEBITORE",
              "LOC DEBITORE", "PROVINCIA DEBITORE", "CELL DEBITORE", "EMAIL DEBITORE",
              "ID OPERAZIONE UNIVOCO", "USERNAME", "NOME", "ACCESSO BACHECA", "INVIO EMAIL",
              "INVIO SMS", "INVIO CARTACEO"]
              
      invoices.each do |invoice|
        setup = Setup.where("building_id = ?", invoice.building_id).first
        invoice_text = "ft.n. #{invoice.number} del #{invoice.created_at.strftime('%d-%m-%Y')}"
        invoice.mavs.each do |mav|
          csv << [  (mav.amount * 100).to_i, 
                    '"' + invoice_text + '"',
                    mav.expiration ? mav.expiration.strftime("%Y-%m-%d") : nil,
                    mav.user.codice_fiscale,
                    mav.user.codice_fiscale,
                    '"' + mav.user.last_name + '"',
                    '"' + [mav.user.lease.invoice_address, mav.user.lease.home_number].join(" ")  + '"',
                    mav.user.lease.cap,
                    '"' + mav.user.lease.localita + '"',
                    mav.user.lease.provincia,
                    nil,
                    setup && setup.erli_mav_email_active? ? setup.erli_mav_email_active : nil,
                    nil,
                    nil,
                    '"' + mav.user.first_name + '"',
                    '"DISABILITATO"',
                    setup && setup.erli_mav_email_active? ? '"ABILITATO"' : '"DISABILITATO"',
                    '"DISABILITATO"',
                    '"DISABILITATO"' ]
        end
      end
    end
  end
  
end
