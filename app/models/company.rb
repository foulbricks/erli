class Company < ActiveRecord::Base
  validates :name, :address, :provincia, :localita, :cap, :partita_iva, :presence => true
  
end
