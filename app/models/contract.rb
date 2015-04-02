class Contract < ActiveRecord::Base
  
  validates :name, :presence => true, :uniqueness => true
  validates :istat, :presence => true, :numericality => true
  
  has_many :leases
  
  before_destroy :check_if_leases_are_present
  
  private
  def check_if_leases_are_present
    if leases.size > 0
      errors[:base] << "Contratto non puo essere eliminato perche ha gia locazioni!"
      return false
    end
  end
  
end
