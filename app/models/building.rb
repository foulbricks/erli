class Building < ActiveRecord::Base
  mount_uploader :background, BackgroundUploader
  
  validates :name, :presence => true, :uniqueness => true
  
  has_many :apartments
  has_many :asset_expenses, as: :asset
  
end
