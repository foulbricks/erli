class Expense < ActiveRecord::Base
  has_many :asset_expenses
  belongs_to :repartition_table
  
  validates :name, :presence => true, :uniqueness => true
  validates :kind, :presence => true
end
