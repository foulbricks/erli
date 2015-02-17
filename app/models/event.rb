class Event < ActiveRecord::Base
  belongs_to :building
  belongs_to :apartment
  belongs_to :user
  belongs_to :lease
  
  validates :start, :finish, :title, :building_id, :presence => true
end
