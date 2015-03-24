class Apartment < ActiveRecord::Base
  belongs_to :building
  has_many :apartment_repartition_tables, :dependent => :destroy
  has_many :leases, :dependent => :destroy
  has_many :asset_expenses, :as => :asset
  has_many :events
  
  after_create do |a|
    RepartitionTable.where(:building_id => a.building.id).all.each do |r|
      r.apartment_repartition_tables.create(:apartment_id => a.id, :percentage => 0, 
                                            :floor => a.floor, :name => a.name)
    end
  end
  
  before_destroy :set_alarm
  after_save :set_alarm
  
  validates :name, :building_id, :rooms, :floor, presence: true
  validates :dimension, :rooms, :floor, :numericality => {:only_integer => true}
  validates :name, uniqueness: {:scope => :building_id}

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
  
  private
  def set_alarm
    event = Event.where("kind ~ 'repartition' AND building_id = ? AND active = true", building_id).first
    desc = RepartitionTable.where("building_id = ?", building_id).all.map {|r| r.name }.join(", ")
    if event
      event.update_columns(:description => desc, :start => Date.today, :finish => Date.today)
    else
      Event.create(:title => "Aggiorna Tabelle di Ripartizione",
                   :description => desc,
                   :building_id => building_id,
                   :color => "#d9534f",
                   :start => Date.today,
                   :finish => Date.today,
                   :kind => "repartition",
                   :active => true)
    end
  end
end
