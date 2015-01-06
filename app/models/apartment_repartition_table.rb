class ApartmentRepartitionTable < ActiveRecord::Base
  belongs_to :apartment
  belongs_to :repartition_table
  
  validates :percentage, :apartment_id, :presence => true
end