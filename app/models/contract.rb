class Contract < ActiveRecord::Base
  attr_localized :istat
  
  validates :name, :presence => true, :uniqueness => true
  validates :istat, :presence => true, :numericality => true
  
  has_many :apartments
end
