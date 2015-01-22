class AssetExpense < ActiveRecord::Base
  belongs_to :asset, polymorphic: true
  belongs_to :expense
  
  validates :expense_id, :amount, :presence => true
  validates :amount, :numericality => true
  
end
