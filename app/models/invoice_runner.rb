class InvoiceRunner < ActiveRecord::Base
  validates :building_id, :generated_date, :presence => true
end
