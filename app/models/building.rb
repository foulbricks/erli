class Building < ActiveRecord::Base
  
  validates_presence_of :name
  has_many :apartments
  has_many :building_expenses
  
end
