class Apartment < ActiveRecord::Base
  belongs_to :building
  has_many :apartment_repartition_tables, :dependent => :destroy
  has_many :leases, :dependent => :destroy
  has_many :asset_expenses, :as => :asset
  
  after_create do |a|
    RepartitionTable.where(:building_id => a.building.id).all.each do |r|
      r.apartment_repartition_tables.create(:apartment_id => a.id, :percentage => 0, 
                                            :floor => a.floor, :name => a.name)
    end
  end
  
  validates :name, :building_id, :rooms, :floor, presence: true
  validates :dimension, :rooms, :floor, :numericality => {:only_integer => true}
  validates :name, uniqueness: true

  def status
    if percentage > 99
      "Occupato"
    elsif percentage < 1
      "Disponibile"
    else
      "Camera disponibile"
    end
  end
  
  def active_leases
    self.leases.where(:active => true).all
  end
  
  def inactive_leases
    self.leases.where(:active => false).all
  end
  
  def percentage
    active_leases.map(&:percentage).sum
  end
end
