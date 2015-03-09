class Ad < ActiveRecord::Base
  has_many :ad_attachments, :dependent => :destroy
  belongs_to :user
  belongs_to :building
  
  accepts_nested_attributes_for :ad_attachments, :reject_if => proc {|attrs| attrs["image"].blank? }
  
  validates :user_id, :building_id, :description, :amount, :contact, :presence => true
  validates :amount, :numericality => true
  
  
end