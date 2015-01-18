class Building < ActiveRecord::Base
  
  validates :name, :presence => true, :uniqueness => true
  
  has_many :apartments
  has_many :asset_expenses, as: :asset
  
end
