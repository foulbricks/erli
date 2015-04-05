class Event < ActiveRecord::Base
  belongs_to :building
  belongs_to :apartment
  belongs_to :user
  belongs_to :lease
  
  validates :start, :finish, :title, :building_id, :presence => true
  
  before_save do |event|
    event.label = event.label.strip.downcase if event.label.present?
  end
end
