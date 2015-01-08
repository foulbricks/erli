class Apartment < ActiveRecord::Base
  belongs_to :building
  has_many :apartment_repartition_tables
  
  validates :name, :building_id, :rooms, :floor, presence: true
  validates :dimension, :rooms, :floor, :numericality => {:only_integer => true}
  validates :name, uniqueness: true

end
