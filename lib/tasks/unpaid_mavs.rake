namespace :unpaid_mavs do
  desc "Sets alarms and sends emails when a MAV is unpaid"
  task :process => :environment do
    Building.all.each do |building|
      unpaid_mavs = Mav.where("building_id = ? AND status = 'Da Pagare' " + 
                               "AND expiration < ? AND document IS NOT NULL", 
                               building.id, Date.today).all
      
      UnpaidAlarm.set_unpaid_alarms(building, unpaid_mavs)
      UnpaidEmail.send_unpaid_emails(building, unpaid_mavs)
    end
  end
end