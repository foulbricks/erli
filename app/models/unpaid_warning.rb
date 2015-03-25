class UnpaidWarning < ActiveRecord::Base
  
  validates :text, :days, :background, :building_id, :presence => true
  validates :days, :numericality => { :only_integer => true }
  
  def self.closest_to_expiration_day(mav, warnings)
    return warnings.first if warnings.size <= 1
    days_expired = mav.days_since_expired
    ws = warnings.sort_by {|w| (w.days - days_expired).abs }[0, 2]
    if days_expired - ws[0].days < 0
      return ws[1]
    else
      return ws[0]
    end
  end
end
