class Company < ActiveRecord::Base
  validates :name, :address, :provincia, :localita, :cap, :partita_iva, :presence => true
  
  
  def welcome(building)
    welcome_text.to_s.gsub(/\[\[\s*edificio\s*\]\]/, building.name)
  end
  
  def forgot_password(building)
    reset_password_text.to_s.gsub(/\[\[\s*edificio\s*\]\]/, building.name)
  end
end
