class Setup < ActiveRecord::Base
  belongs_to :building
  
  validates :iva, :istat, :mav_expiration, :invoice_generation, 
            :invoice_delivery, :unpaid_sentence, :erli_mav_email, :erli_admin_email, 
            :building_id, presence: true, on: :update
            
  validates :mav_expiration, :invoice_generation, :invoice_delivery, 
            :numericality => {:only_integer => true, :minimum => 1, :maximum => 28}
            
  validates :building_id, presence: true, on: :create

  
end
