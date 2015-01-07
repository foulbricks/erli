class BolloRange < ActiveRecord::Base
  has_many :bollos
  
  validates :from, :to, :presence => true, :numericality => {:only_integer => true}
end
