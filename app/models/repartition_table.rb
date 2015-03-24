class RepartitionTable < ActiveRecord::Base
  belongs_to :building
  
  has_many :expenses
  has_many :apartment_repartition_tables, -> { order "floor asc, name asc" }, dependent: :destroy
  
  accepts_nested_attributes_for :apartment_repartition_tables
  
  validates :name, :building_id, :presence => true
  validates :name, :uniqueness => {scope: :building_id}
  validates_associated :apartment_repartition_tables
  
  after_save :clear_alarm
  before_destroy :clear_alarm
  
  def self.build(building_id)
    table = self.new(:building_id => building_id)
    table.building.apartments.order("floor asc, name asc").each do |a|
      table.apartment_repartition_tables.build(:apartment_id => a.id, :floor => a.floor, :name => a.name)
    end
    table
  end
  
  private
  def clear_alarm
    if event = Event.where("kind ~ 'repartition' AND building_id = ? AND active = true", building_id).first
      desc_array = event.description.split(", ")
      desc_array.delete(name)
      if desc_array.blank?
        event.destroy
      else
        event.update_column(:description, desc_array.join(", "))
      end
    end
  end
end