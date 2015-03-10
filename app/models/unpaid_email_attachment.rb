class UnpaidEmailAttachment < ActiveRecord::Base
  mount_uploader :document, DocumentUploader
  
  belongs_to :unpaid_email
  
  validates_presence_of :document
  
end
