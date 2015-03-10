class LeaseAttachment < ActiveRecord::Base
  belongs_to :lease
  mount_uploader :document, DocumentUploader
  
  validates :lease_id, :document, :presence => true 
  
end
