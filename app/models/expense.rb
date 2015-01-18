class Expense < ActiveRecord::Base
  has_many :asset_expenses
  belongs_to :repartition_table
  
  before_save :add_to_invoice_for_apartment
  
  validates :name, :presence => true, :uniqueness => {:scope => :building_id}
  validates :kind, :building_id, :presence => true
  validates :repartition_table_id, :presence => true, :if => "kind == 'Edificio'"
  
  private
  def add_to_invoice_for_apartment
    self.add_to_invoice = true if kind =~ /appartamento/i
  end
end
