class Bollo < ActiveRecord::Base
  belongs_to :invoice
  
  validates :identifier, :presence => true, :uniqueness => true
  validates :price, :presence => true
  
end
