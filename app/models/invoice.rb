class Invoice < ActiveRecord::Base
  has_many :invoice_charges, :dependent => :destroy
  
  
  def generate(building_id)
    
  end
  
  def self.generate_rent(invoice, lease, invoice_date)
    if lease.registration_date.present? && (lease.start_date..lease.end_date).include?(invoice_date)
      date_tables = lease.date_tables(invoice_date)
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
  # This lease is for less than lease frequency - charge full price
  # This lease started last month and it hasn't been charged last month
  # This lease ends this period
  # Regular price
  def self.charge_amount(lease, charge_date)
    charges = lease.invoice_charges.where(:kind => "rent").all
    
    if lease.lease_months <= lease.payment_frequency
      charges.size == 0 ? lease.amount : 0 
    elsif lease.partial_month? && same_month?(charge_date.prev_month, lease.start_date) && charges.size < 1
      (lease.monthly_charge * lease.payment_frequency) + partial_charge(lease)
    elsif same_period?(charge_date, lease.end_date, lease.payment_frequency)
      total_charges_so_far = charges.map(&:amount).sum
      lease.amount - total_charges_so_far
    else
      lease.monthly_charge * lease.payment_frequency
    end
  end
  
  def self.charge_amount_with_istat(lease, charge_date)
    amount = charge_amount(lease, charge_date)
    period = charge_period(lease, charge_date)
    istat_date = lease.start_date + 12.months
    
    if lease.lease_months > 12 && lease.contract.istat > 0
      setup_istat = Setup.first.try(:istat) || 0
      contract_ratio = lease.contract.istat/100.0
      setup_ratio = setup_istat > 0 ? setup_istat/100.0 : 1
      
      if period.first >= istat_date 
        amount + (amount * contract_ratio * setup_ratio)
      elsif period.include?(istat_date))
        num_days = (istat_date..period.last).count
        amount + (num_days * lease.daily_charge * contract_ratio * setup_ratio)
      else
        amount
      end
    else
      amount
    end
  end
  
  def self.partial_charge(lease)
    num_days = (lease.start_date..lease.start_date.end_of_month).count
    month_percent = num_days/lease.start_date.end_of_month.mday.to_f
    (month_percent * lease.monthly_charge * 100).round / 100.0
  end
  
  def self.same_month?(date1, date2)
     date1.at_beginning_of_month == date2.at_beginning_of_month
  end
  
  def self.same_period?(from_date, include_date, months)
    (from_date..(from_date + months)).include?(include_date)
  end
  
  def self.charge_period(lease, charge_date)
    from = charge_date.at_beginning_of_month
    to = from + (lease.payment_frequency).months
    to = lease.end_date if to > lease.end_date
    if same_month?(charge_date.prev_month, lease.start_date) || same_month?(charge_date, lease.start_date)
      from = lease.start_date
    end
    (from..to)
  end
  
  def self.month_description(period)
    start, to = period.first, period.last
    from, names = start, []
    while from < to
      names << [I18n.t("dates.month_names")[from.month], from.year]
      from = from.end_of_month + 1.day
    end
    str = names.size > 1 ? "Mesi di " : "Mese di "
    h = names.group_by {|n| n[1] }
    h.each do |year, val|
      str = val.map{|m| m[0] }.join(" ") + " #{year}"
    end
    str
  end
  
  # def date_tables(stop_date)
  #   ranges = []
  #   from = start_date
  #   while from < end_date && from <= stop_date
  #     to = end_date.end_of_month == from.end_of_month ? end_date : from.end_of_month
  #     ranges << (from..to)
  #     from = from.next_month.at_beginning_of_month
  #   end
  #   ranges
  # end
  
end