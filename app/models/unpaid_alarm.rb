class UnpaidAlarm < ActiveRecord::Base
  validates :body, :days, :building_id, :presence => true
  validates :days, :numericality => { :only_integer => true }
end
