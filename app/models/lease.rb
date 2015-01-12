class Lease < ActiveRecord::Base
  attr_localized :percentage, :deposit, :amount
  
  belongs_to :apartment
  has_many :users
  
  accepts_nested_attributes_for :users
  
  validates :percentage, :contract_id, :apartment_id, :invoice_address, :start_date,
            :end_date, :amount, :payment_frequency, :deposit, :registration_date,
            :registration_number, :registration_agency, :presence => true
            
  validates :percentage, :numericality => {:minimum => 0, :maximum => 100}
  validates :contract_id, :apartment_id, :payment_frequency, :registration_number, :numericality => {:only_integer => true}
  validates :deposit, :amount, :numericality => true
  validates_associated :users
  
end
