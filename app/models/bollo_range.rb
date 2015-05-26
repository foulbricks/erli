class BolloRange < ActiveRecord::Base
  
  has_many :bollos
  
  before_destroy :check_it_doesnt_have_invoices
  
  validates :from, :to, :presence => true, :numericality => {:only_integer => true}
  validates :price, :presence => true
  
  def check_it_doesnt_have_invoices
    if bollos.size > 0
      if bollos.inject(0) {|s, b| s += 1 if !b.invoice.nil?; s } > 0
        errors.add(:base, "aveve fatture")
        return false
      end
    end
  end
end
