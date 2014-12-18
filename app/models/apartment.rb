class Apartment < ActiveRecord::Base
  
  validates_presence_of :name, :status
  belongs_to :building
  
end
