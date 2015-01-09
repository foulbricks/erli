class Apartment < ActiveRecord::Base
  belongs_to :building
  has_many :apartment_repartition_tables, :dependent => :destroy
  
  after_create do |a|
    RepartitionTable.all.each do |r|
      r.apartment_repartition_tables.create(:apartment_id => a.id, :percentage => 0, 
                                            :floor => a.floor, :name => a.name)
    end
  end
  
  validates :name, :building_id, :rooms, :floor, presence: true
  validates :dimension, :rooms, :floor, :numericality => {:only_integer => true}
  validates :name, uniqueness: true

end
