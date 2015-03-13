class UnpaidEmail < ActiveRecord::Base
  has_many :unpaid_email_attachments, :dependent => :destroy
  
  accepts_nested_attributes_for :unpaid_email_attachments, :reject_if => proc {|attrs| attrs["document"].blank? }, :allow_destroy => true
  
  validates :body, :days, :frequency, :building_id, :presence => true
  validates :days, :frequency, :numericality => { :only_integer => true }
end