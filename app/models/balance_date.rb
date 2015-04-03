class BalanceDate < ActiveRecord::Base
  has_many :expenses, :dependent => :nullify
  belongs_to :building
  
  validates :value, :building_id, :presence => true
  
  def value_it_locale
    value.strftime("%d-%m-%Y")
  end
end
