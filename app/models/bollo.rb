class Bollo < ActiveRecord::Base

  belongs_to :invoice
  belongs_to :bollo_range
  
  before_destroy :check_if_invoice_is_present
  
  validates :identifier, :presence => true, :uniqueness => true
  validates :price, :bollo_range_id, :presence => true
  
  private
  def check_if_invoice_is_present
    if invoice_id.present?
      errors[:base] << "Bollo non puo essere eliminato perche ha gia una fattura!"
      return false
    end
  end
  
end
