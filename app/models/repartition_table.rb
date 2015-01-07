class RepartitionTable < ActiveRecord::Base
  belongs_to :building
  
  has_many :expenses, dependent: :destroy
  has_many :apartment_repartition_tables, dependent: :destroy
  
  accepts_nested_attributes_for :apartment_repartition_tables
  
  validates :name, :building_id, :presence => true
  validates :name, :uniqueness => true
  validates_associated :apartment_repartition_tables
  
  def self.build(building_id)
    table = self.new(:building_id => building_id)
    table.building.apartments.each do |a|
      table.apartment_repartition_tables.build(:apartment_id => a.id)
    end
    table
  end
end