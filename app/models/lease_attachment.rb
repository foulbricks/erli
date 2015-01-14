class LeaseAttachment < ActiveRecord::Base
  mount_uploader :document, DocumentUploader
  
  validates :lease_id, :document, :presence => true 
  
end
