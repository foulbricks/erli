class Expense < ActiveRecord::Base
  has_many :asset_expenses
  belongs_to :repartition_table
  belongs_to :balance_date
  
  before_destroy :check_if_asset_expenses_are_present
  
  validates :name, :presence => true, :uniqueness => {:scope => :building_id}
  validates :kind, :building_id, :presence => true
  validates :repartition_table_id, :presence => true, :if => "kind == 'Edificio'"
  
  private
  # def add_to_invoice_for_apartment
  #   self.add_to_invoice = true if kind =~ /appartamento/i
  # end
  
  def check_if_asset_expenses_are_present
    if asset_expenses.size > 0
      errors[:base] << "Tipo di spesa non puo essere eliminata perche ha gia spese!"
      return false
    end
  end
end
