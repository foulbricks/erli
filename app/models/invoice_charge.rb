class InvoiceCharge < ActiveRecord::Base
  belongs_to :invoice
  belongs_to :asset_expense
  
  validates :amount, :presence => true
  validates_numericality_of :amount
  
  def generated_name
    if kind == "rent"
      "Importo del Canone di Locazione"
    elsif kind == "custom_expense"
      name
    else
      asset_expense.expense.name
    end
  end
end
