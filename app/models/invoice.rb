class Invoice < ActiveRecord::Base
  has_many :invoice_charges, :dependent => :destroy
  
  
  def generate(building_id)
    
  end
  
  def self.generate_rent(invoice, lease, invoice_date)
    if lease.registration_date.present? && (lease.start_date..lease.end_date).include?(invoice_date)
      date_tables = Invoice.date_tables(lease.start_date, lease.end_date, invoice_date)
      rent_charges = lease.invoices.all.map do |invoice|
        invoice.invoice_charges.where(:kind => "Rent").all
      end.compact
      
      if lease.start_date.at_beginning_of_month == Date.today.prev_month.at_beginning_of_month
        unless rent_charges.detect {|c| c.start_date == lease.start_date }
          total = (lease.start_date..lease.start_date.end_of_month).entries.size / amount
          invoice.invoice_charges.build(:amount => amount, 
                                        :start_date => lease.start_date)
        end
      end
    end
    
  end
  
  def self.apartment_expenses(apartment, lease)
    apartment.asset_expenses.where("invoice_id IS NULL AND lease_id = ? AND paid_on IS NULL", lease.id).all
  end
  
  def self.registered_leases(building_id)
    Lease.where("active = ? AND building_id = ? AND registration_date IS NOT NULL AND registration_date <> ''",
                true, building_id).all
  end
  
  private
  def self.rent_percentage(lease)
    if lease.start_date.next_month <= lease.end_date
      1
    elsif lease.start_date.at_beginning_of_month == lease.end_date.at_beginning_of_month
      1
    elsif lease.start_date.at_beginning_of_month == Date.today.prev_month.at_beginning_of_month
      (lease.start_date..lease.start_date.end_of_month).entries.size
    end
  end
  
  def self.date_tables(start_date, end_date, invoice_date)
    ranges = []
    from = start_date
    while from < end_date && from <= invoice_date
      to = end_date.end_of_month == from.end_of_month ? end_date : from.end_of_month
      ranges << (from..to)
      from = from.next_month.at_beginning_of_month
    end
    ranges
  end
end