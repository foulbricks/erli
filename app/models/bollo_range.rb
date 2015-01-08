class BolloRange < ActiveRecord::Base
  attr_localized :price
  
  has_many :bollos
  
  before_destroy :check_it_doesnt_have_invoices
  
  validates :from, :to, :presence => true, :numericality => {:only_integer => true}
  validates :price, :presence => true
  
  def check_it_doesnt_have_invoices
    if bollos.size > 0
      errors.add(:base, "it has bollos")
      return false
    end
  end
end
