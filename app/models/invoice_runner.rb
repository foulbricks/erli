class InvoiceRunner < ActiveRecord::Base
  validates :lease_id, :generated_date, :presence => true
end
