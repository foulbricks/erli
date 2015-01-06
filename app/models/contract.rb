class Contract < ActiveRecord::Base
  validates :name, :presence => true
  validates :istat, :presence => true, :numericality => true
  
  has_many :apartments
end
