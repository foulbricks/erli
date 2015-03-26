namespace :unpaid_mavs do
  desc "Sets alarms and sends emails when a MAV is unpaid"
  task :process => :environment do
    Building.all.each do |building|
      unpaid_mavs = Mav.where("building_id = ? AND status = 'Da Pagare' " + 
                               "AND expiration < ? AND document IS NOT NULL", building.id, Date.today).all
      emails = UnpaidEmail.where("building_id = ?", building.id).all
      alarms = UnpaidAlarm.where("building_id = ?", building.id).all
      
      unpaid_mavs.each do |mav|
        if mav.user
          days = mav.days_since_expired
          
          # Send emails
          emails.each do |email|
            if email.days == days || (email.days > days && days % email.frequency == 0)
              UserMailer.unpaid_mav(mav, email).deliver
            end
          end
          
          # Set alarms
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
end