class AdAttachment < ActiveRecord::Base
  mount_uploader :image, ImageUploader
  
  belongs_to :ad
  
  validates_presence_of :image
end