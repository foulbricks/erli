namespace :invoices do
  desc "Generates invoices depending on day set on setup"
  task :generate => :environment do
    Building.all.each do |building|
      setup = Setup.where(:building_id => building.id).first
      if setup
        if Date.today.mday == setup.invoice_generation
          Invoice.generate(building.id, Date.today) 
        end
      end
    end
  end
end