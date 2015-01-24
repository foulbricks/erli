class AssetExpense < ActiveRecord::Base
  belongs_to :asset, polymorphic: true
  belongs_to :expense
  has_one :expense_attachment, :dependent => :destroy
  
  accepts_nested_attributes_for :expense_attachment, :reject_if => proc {|attrs| attrs["document"].blank? }
  
  validates :expense_id, :amount, :presence => true
  validates :amount, :numericality => true
  
end
