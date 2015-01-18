class RepartitionTable < ActiveRecord::Base
  belongs_to :building
  
  has_many :expenses
  has_many :apartment_repartition_tables, -> { order "floor asc, name asc" }, dependent: :destroy
  
  accepts_nested_attributes_for :apartment_repartition_tables
  
  validates :name, :building_id, :presence => true
  validates :name, :uniqueness => {scope: :building_id}
  validates_associated :apartment_repartition_tables
  
  def self.build(building_id)
    table = self.new(:building_id => building_id)
    table.building.apartments.order("floor asc, name asc").each do |a|
      table.apartment_repartition_tables.build(:apartment_id => a.id, :floor => a.floor, :name => a.name)
    end
    table
  end
end