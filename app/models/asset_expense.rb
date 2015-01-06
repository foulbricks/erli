class AssetExpense < ActiveRecord::Base
  belongs_to :asset, polymorphic: true
  belongs_to :expense
  
  validates_associated :asset, :expense
  
end
