class Contract < ActiveRecord::Base
  
  validates :name, :presence => true, :uniqueness => true
  validates :istat, :presence => true, :numericality => true
  
  has_many :apartments
end
