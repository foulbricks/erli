class AssetExpense < ActiveRecord::Base
  belongs_to :asset, polymorphic: true
  belongs_to :expense
  
  validates :asset_id, :asset_type, :expense_id, :amount, :presence => true
  validates :amount, :numericality => true
  
end
