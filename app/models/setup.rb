class Setup < ActiveRecord::Base
  belongs_to :building
  
  validates :balance_expenses, :iva, :istat, :mav_expiration, :invoice_generation, 
            :invoice_delivery, :unpaid_sentence, :erli_mav_email, :erli_admin_email, 
            :building_id, presence: true, on: :update
            
  validates :building_id, presence: true, on: :create

  
end
