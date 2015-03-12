class MavCsv < ActiveRecord::Base
  has_many :invoices
  
  validates :building_id, :presence => true
  
  def generate_csv
    CSV.generate({:col_sep: ";"}) do |csv|
      csv << ["IMPORTO IN CENTESIMI", "CAUSALE PAGAMENTO", "SCADENZA PAGAMENTO", "COD DEBITORE",
              "CF o PIVA", "COGNOME O RAGIONE SOCIALE", "INDIRIZZO DEBITORE", "CAP DEBITORE",
              "LOC DEBITORE", "PROVINCIA DEBITORE", "CELL DEBITORE", "EMAIL DEBITORE",
              "ID OPERAZIONE UNIVOCO", "USERNAME", "NOME", "ACCESSO BACHECA", "INVIO EMAIL",
              "INVIO SMS", "INVIO CARTACEO"]
              
      invoices.each do |invoice|
        setup = Setup.where("building_id = ?", invoice.building_id).first
        invoice.mavs.each do |mav|
          csv << [  mav.amount * 100, 
                    "ft.n. #{invoice.number} del #{invoice.created_at.strftime('%d-%m-%Y')}",
                    mav_expiration(setup, invoice).strftime("%Y-%m-%d"),
                    mav.user.codice_fiscale,
                    mav.user.codice_fiscale,
                    mav.user.last_name,
                    [mav.user.lease.invoice_address, mav.user.lease.home_number].join(" "),
                    mav.user.lease.cap,
                    mav.user.lease.localita,
                    mav.user.lease.provincia,
                    "",
                    setup.erli_mav_email_active? ? setup.erli_mav_email_active : "",
                    "",
                    "",
                    mav.user.first_name,
                    "DISABILITATO",
                    setup.erli_mav_email_active? ? "ABILITATO" : "DISABILITATO",
                    "DISABILITATO",
                    "DISABILITATO" ]
        end
      end
    end
  end
  
  private
  def mav_expiration(setup, invoice)
    if setup.mav_expiration.present?
      expire = invoice.created_at.change(:day => setup.mav_expiration)
    else
      expire = invoice.created_at.end_of_month
    end
    expire = expire.next_month if expire <= invoice.created_at
    expire
  end
  
end
