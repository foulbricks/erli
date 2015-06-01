class Company < ActiveRecord::Base
  validates :name, :address, :provincia, :localita, :cap, :partita_iva, :presence => true, :unless => "istat.present? or iva.present?"
  
  
  def welcome(building, user=nil)
    text = welcome_text.to_s
    text.gsub!(/\[\[\s*edificio\s*\]\]/, building.name)
    text.gsub!(/\[\[\s*email\s*\]\]/, user.email) if user
    text
  end
  
  def forgot_password(building, user=nil)
    text = reset_password_text.to_s
    text.gsub!(/\[\[\s*edificio\s*\]\]/, building.name) if building
    text.gsub!(/\[\[\s*email\s*\]\]/, user.email) if user
    text
  end
end
