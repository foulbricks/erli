class ExpenseAttachment < ActiveRecord::Base
  mount_uploader :document, DocumentUploader
  
  validates :document, :presence => true 
  
end
