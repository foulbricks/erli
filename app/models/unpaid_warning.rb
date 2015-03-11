class UnpaidWarning < ActiveRecord::Base
  
  validates :text, :days, :background, :building_id, :presence => true
  validates :days, :numericality => { :only_integer => true }
end
