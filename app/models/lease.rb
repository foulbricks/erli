class Lease < ActiveRecord::Base
  attr_localized :percentage, :deposit, :amount
  
  belongs_to :apartment
  belongs_to :contract
  has_many :users
  
  accepts_nested_attributes_for :users
  
  validates :percentage, :contract_id, :apartment_id, :invoice_address, :start_date,
            :end_date, :amount, :payment_frequency, :deposit, :presence => true
            
  validates :percentage, :numericality => {:minimum => 0, :maximum => 100}
  validates :contract_id, :apartment_id, :payment_frequency, :numericality => {:only_integer => true}
  validates :registration_number, :numericality => {:only_integer => true}, :allow_blank => true
  validates :deposit, :amount, :numericality => true
  validate :percentage_maximum
  
  def percentage_maximum
    if apartment_id
      ids = Apartment.find(apartment_id).lease_ids
      ids.delete(self.id) 
      if Lease.where("id IN (?)", ids).all.map(&:percentage).sum + percentage > 100
        errors.add(:percentage, "per il appartamento e superiore a 100")
      end
    end
  end
end
