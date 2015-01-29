class InvoiceCharge < ActiveRecord::Base
  belongs_to :invoice
  belongs_to :asset_expense
  
  validates :amount, :presence => true
end
