class ApartmentRepartitionTable < ActiveRecord::Base
  belongs_to :apartment
  belongs_to :repartition_table
  
  validates :percentage, :apartment_id, :presence => true
  validates :percentage, :numericality => {:minumum => 0, :maximum => 100}
end