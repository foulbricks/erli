class Lease < ActiveRecord::Base
  
  belongs_to :apartment
  belongs_to :contract
  has_many :users, :dependent => :destroy
  has_many :lease_attachments, :dependent => :destroy
  
  accepts_nested_attributes_for :users
  accepts_nested_attributes_for :lease_attachments, reject_if: proc { |attributes| attributes['document'].blank? }
  
  validates :percentage, :contract_id, :apartment_id, :invoice_address, :start_date,
            :end_date, :amount, :payment_frequency, :deposit, :presence => true
            
  validates :percentage, :numericality => {:minimum => 0, :maximum => 100}
  validates :contract_id, :apartment_id, :payment_frequency, :numericality => {:only_integer => true}
  validates :registration_number, :numericality => {:only_integer => true}, :allow_blank => true
  validates :deposit, :amount, :numericality => true
  validate :percentage_maximum
  
  before_save do |l|
    u = l.new_record? ? l.users.first : l.users.where(:secondary => false).first
    if u
      l.name = u.name
      l.email = u.email
      l.codice_fiscale = u.codice_fiscale
    end
  end
  
  def address
    [invoice_address, cap, localita, provincia].join(" ")
  end
  
  def searchable_attributes
    [contract.name, address, cap, localita, provincia, start_date.strftime("%d-%m-%Y"),
     end_date.strftime("%d-%m-%Y"), registration_date.strftime("%d-%m-%Y"), amount.to_s,
     payment_frequency.to_s + " Mesi", deposit.to_s, registration_number.to_s, registration_agency,
     payment_frequency.to_s + " Mese", name, codice_fiscale, email].join(" ")
  end
  
  private
  
  def percentage_maximum
    if apartment_id
      ids = Apartment.find(apartment_id).active_leases.map(&:id)
      ids.delete(self.id) 
      if Lease.where("id IN (?)", ids).all.map(&:percentage).sum + percentage > 100
        errors.add(:percentage, "per il appartamento e superiore a 100")
      end
    end
  end
end
