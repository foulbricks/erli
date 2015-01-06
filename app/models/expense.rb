class Expense < ActiveRecord::Base
  has_many :asset_expenses
  
  validates :name, :presence => true, :uniqueness => true
  validates :kind, :presence => true
end
