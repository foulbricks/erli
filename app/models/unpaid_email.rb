class UnpaidEmail < ActiveRecord::Base
  has_many :unpaid_email_attachments, :dependent => :destroy
  
  accepts_nested_attributes_for :unpaid_email_attachments, :reject_if => proc {|attrs| attrs["document"].blank? }, :allow_destroy => true
  
  validates :body, :days, :frequency, :building_id, :presence => true
  validates :days, :frequency, :numericality => { :only_integer => true }
  
  
  def self.send_unpaid_emails(building, unpaid_mavs)
    emails = UnpaidEmail.where("building_id = ?", building.id).all
    unpaid_mavs.each do |mav|
      if mav.user
        days = mav.days_since_expired
        
        # Send emails
        emails.each do |email|
          if email.days == days || (days > email.days && days % email.frequency == 0)
            UserMailer.unpaid_mav(mav, email).deliver
          end
        end
      end
    end
  end
end