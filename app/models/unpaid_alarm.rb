class UnpaidAlarm < ActiveRecord::Base
  validates :body, :days, :building_id, :presence => true
  validates :days, :numericality => { :only_integer => true }
  
  def self.set_unpaid_alarms(building, unpaid_mavs)
    alarms = UnpaidAlarm.where("building_id = ?", building.id).all
    unpaid_mavs.each do |mav|
      if mav.user
        days = mav.days_since_expired

        alarms.each do |alarm|
          if alarm.days == days
            Event.create(:title => alarm.body,
                         :description => "",
                         :building_id => building.id,
                         :apartment_id => mav.user.lease.apartment.id,
                         :user_id => mav.user.id,
                         :color => "#d9534f",
                         :start => Date.today,
                         :finish => Date.today,
                         :kind => "unpaid alarm",
                         :active => true)
          end
        end
      end
    end
  end
end
