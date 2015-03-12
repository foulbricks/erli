require "csv"

class Mav < ActiveRecord::Base
  belongs_to :invoice
  belongs_to :building
  belongs_to :user
  
  validates :user_id, :building_id, :invoice_id, :presence => true
  
  def amount
    ((invoice.total * user.percentage / 100) * 100).round / 100.0
  end
end
