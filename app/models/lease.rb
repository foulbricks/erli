class Lease < ActiveRecord::Base
  belongs_to :apartment
  has_many :users
  
  accepts_nested_attributes_for :users
end
