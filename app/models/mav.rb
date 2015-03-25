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
  
  def status
    "Pagato"
  end
end
