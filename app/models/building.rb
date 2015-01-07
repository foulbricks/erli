class Building < ActiveRecord::Base
  
  validates :name, :presence => true, :uniqueness => true
  
  has_many :apartments
  has_many :building_expenses
  
end
