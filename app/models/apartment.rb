class Apartment < ActiveRecord::Base
  belongs_to :building
  has_many :apartment_repartition_tables
  
  validates :name, :building_id, presence: true
  validates :name, uniqueness: true

end
