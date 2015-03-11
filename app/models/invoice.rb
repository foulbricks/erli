class Invoice < ActiveRecord::Base
  attr_accessor :temporary_bollo
  
  mount_uploader :document, DocumentUploader
  has_many :invoice_charges, :dependent => :destroy
  has_many :asset_expenses
  has_one :bollo
  belongs_to :lease
  
  validates_presence_of :lease_id
  
  accepts_nested_attributes_for :invoice_charges, reject_if: proc { |attributes| attributes['amount'].blank? }
  
  before_destroy do |i|
    i.asset_expenses.all.each do |e|
      e.update_column(:invoice_id, nil)
    end
  end
  
  before_save do |i|
    self.total = Invoice.calculate_total(self.lease, self)
  end
  
  def approved?
    approved #or Date.today >= (start_date + 1.month)
  end
  
  def self.generate(building_id, invoice_date=Date.today)
    registered_leases(building_id, invoice_date).each do |lease|
        invoice = self.new(:building_id => building_id, :number => get_invoice_number(lease, invoice_date),
                           :lease_id => lease.id, :start_date => invoice_date.at_beginning_of_month,
                           :end_date => invoice_date.end_of_month)
        
        charge_rent(lease, invoice, invoice_date)
        charge_building_expenses(lease, invoice, invoice_date)
        charge_apartment_expenses(lease, invoice, invoice_date)
        invoice.temporary_bollo = get_available_bollo(invoice)
        
        temp = Invoice.tempfile(Invoice.render_pdf(invoice.lease, invoice, invoice_date))
        invoice.document = File.open temp.path
        temp.unlink
        
        if invoice.save
          invoice.temporary_bollo.update_column(:invoice_id, invoice.id) if invoice.temporary_bollo
          invoice.invoice_charges.where(:kind => "apartment_expense").all.each do |i|
            i.asset_expense.update_column(:invoice_id, invoice.id)
          end
        end
    end
  end
  
  def self.apartment_expenses(lease)
    lease.apartment.asset_expenses.where("invoice_id IS NULL AND lease_id = ? and balance_date IS NULL", lease.id).all
  end
  
  def self.registered_leases(building_id, invoice_date=Date.today)
    apartment_ids = Apartment.where(:building_id => building_id).all.map(&:id)
    Lease.where("active = ? AND apartment_id IN (?) AND registration_date IS NOT NULL AND end_date >= ?",
                true, apartment_ids, invoice_date).all
  end
  
  def self.charge_rent(lease, invoice, invoice_date=Date.today)
    if charge_rent?(lease, invoice_date) && (lease.start_date..lease.end_date).include?(invoice_date)
      rent = invoice.invoice_charges.build(:kind => "rent", :lease_id => lease.id)
      period = charge_period(lease, invoice_date)
      rent.start_date, rent.end_date = period.first, period.last
      rent.amount = charge_amount_with_istat(lease, invoice_date)
    end
  end
  
  def self.charge_apartment_expenses(lease, invoice, invoice_date=Date.today)
    apartment_expenses(lease).each do |e|
      invoice.invoice_charges.build(:kind => "apartment_expense", :lease_id => lease.id, :iva_exempt => false,
        :amount => e.amount, :start_date => invoice.start_date, :end_date => invoice.end_date, :asset_expense_id => e.id)
    end
  end
  
  def self.calculate_total(lease, invoice)
    bollo = invoice.bollo || invoice.temporary_bollo
    without_iva = invoice.invoice_charges.select {|i| i.iva_exempt? }
    with_iva = invoice.invoice_charges.select {|i| !i.iva_exempt? }
    total_iva = with_iva.map(&:amount).sum
    total_without_iva = without_iva.map(&:amount).sum
    setup = Setup.where(:building_id => lease.apartment.building.id).first || Setup.new
    iva = lease.contract.try(:iva_exempt?) || !setup.iva ? 0 : (total_iva * setup.iva/100.0)
    bollo_total = bollo ? bollo.price : 0
    total_iva + total_without_iva + iva + bollo_total
  end
  
  def self.charge_building_expenses(lease, invoice, invoice_date=Date.today)
    lease.asset_expenses.each do |lexpense|
      charge_start = invoice.start_date
      charge_end = invoice.end_date
      
      if lexpense.expense
        balance_date = lexpense.expense.balance_date.value
        if same_month?(balance_date, invoice_date.prev_month) || (same_month?(balance_date, invoice_date) && balance_date <= invoice_date)
          aexpenses = lease.apartment.asset_expenses.where("balance_date IS NOT NULL AND expense_id = ? AND " +
           "start_date <= ?::date AND end_date >= ?::date", lexpense.expense.id, lease.end_date, lease.start_date).all
          if aexpenses.size > 0
            expense_calc = expense_total_charge(aexpenses, lease)
            amount = lease.end_date > invoice_date ? lexpense.amount : 0
            total =  expense_calc + amount - total_expense_charges(lease, lexpense)
            invoice.invoice_charges.build(:kind => "building_expense", :lease_id => lease.id,
              :iva_exempt => lexpense.expense.iva_exempt, :amount => total, :start_date => charge_start,
              :end_date => charge_end, :asset_expense_id => lexpense.id)
          else
            invoice.invoice_charges.build(:kind => "building_expense", :lease_id => lease.id, 
              :iva_exempt => lexpense.expense.iva_exempt, :amount => lexpense.amount, :start_date => charge_start,
              :end_date => charge_end, :asset_expense_id => lexpense.id)
          end
        else
          invoice.invoice_charges.build(:kind => "building_expense", :lease_id => lease.id, 
            :iva_exempt => lexpense.expense.iva_exempt, :amount => lexpense.amount, :start_date => charge_start,
            :end_date => charge_end, :asset_expense_id => lexpense.id)
        end
      end
    end
  end
  
  def self.expense_total_charge(expenses, lease)
    total = 0
    expenses.each do |expense|
      if lease.start_date >= expense.start_date && lease.end_date >= expense.end_date
        total += expense.amount
      else
        if lease.start_date >= expense.start_date && lease.end_date <= expense.end_date
          num_days = (lease.start_date..lease.end_date).count
        elsif lease.start_date >= expense.start_date && lease.end_date >= expense.end_date
          num_days = (lease.start_date..expense.end_date).count
        else
          num_days = (expense.start_date..lease.end_date).count
        end
        expense_num_days = (expense.start_date..expense.end_date).count
        total += num_days/expense_num_days.to_f * expense.amount
      end
    end
    total
  end
  
  def self.total_expense_charges(lease, expense)
    lease.invoice_charges.where(:kind => "building_expense", :asset_expense_id => expense.id).all.map(&:amount).sum
  end
  
  
  # This lease is for less than lease frequency - charge full price
  # This lease started last month and it hasn't been charged last month
  # This lease ends this period
  # Regular price
  def self.charge_amount(lease, charge_date)
    charges = lease.invoice_charges.where(:kind => "rent").all
    
    if lease.lease_months <= lease.payment_frequency
      a = charges.size == 0 ? lease.amount : 0 
    elsif lease.partial_start_date? && same_month?(charge_date.prev_month, lease.start_date) && charges.size < 1
      a = (lease.monthly_charge * lease.payment_frequency) + partial_charge(lease)
    elsif same_period?(charge_date, lease.end_date, lease.payment_frequency)
      total_charges_so_far = charges.map(&:amount).sum
      a = lease.amount - total_charges_so_far
    else
      a = lease.monthly_charge * lease.payment_frequency
    end
    (a * 100).round / 100.0
  end
  
  def self.charge_amount_with_istat(lease, charge_date)
    amount = charge_amount(lease, charge_date)
    period = charge_period(lease, charge_date)
    istat_date = lease.start_date + 12.months
    
    if lease.lease_months > 12 && lease.contract && lease.contract.istat > 0
      setup_istat = Setup.first.try(:istat) || 0
      contract_ratio = lease.contract.istat/100.0
      setup_ratio = setup_istat > 0 ? setup_istat/100.0 : 1
      
      if period.first >= istat_date 
        a = amount + (amount * contract_ratio * setup_ratio)
        (a * 100).round / 100.0
      elsif period.include?(istat_date)
        num_days = (istat_date..period.last).count
        a = amount + (num_days * lease.daily_charge * contract_ratio * setup_ratio)
        (a * 100).round / 100.0
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
    (from_date..(from_date + months.months)).include?(include_date)
  end
  
  def self.charge_period(lease, charge_date)
    from = charge_date.at_beginning_of_month
    to = from + (lease.payment_frequency).months
    to = lease.end_date if to > lease.end_date
    if (same_month?(charge_date.prev_month, lease.start_date) && charge_date.mday < lease.start_date.mday) || 
        same_month?(charge_date, lease.start_date)
      from = lease.start_date
    end
    (from..to)
  end
  
  def self.month_description(period)
    start, to = period.first, period.last
    from, names = start, []
    while from < to
      names << [I18n.t("date.month_names")[from.month], from.year]
      from = from.end_of_month + 1.day
    end
    str = names.size > 1 ? "Mesi di " : "Mese di "
    h = names.group_by {|n| n[1] }
    h.each do |year, val|
      str += val.map{|m| m[0].capitalize }.join(", ") + " #{year} "
    end
    str.chop
  end
  
  def self.charge_rent?(lease,charge_date)
    return true if lease.start_date > charge_date - 1.month && lease.end_date <= charge_date
    tables = date_tables(charge_date, lease.start_date, lease.end_date, lease.payment_frequency)
    tables.last.first == charge_date.at_beginning_of_month
  end
  
  def self.date_tables(stop_date, start_date, end_date, step)
    ranges = []
    months = step == 1 ? 0 : step
    from = start_date
    while from < end_date && from <= stop_date
      in_end_date = same_period?(from.end_of_month, end_date.end_of_month, step)
      to = in_end_date ? end_date : (from.end_of_month + months.months)
      ranges << (from..to)
      from = from.next_month.at_beginning_of_month + months.months
    end
    ranges
  end
  
  def self.renderer
    av = ActionView::Base.new()
    av.view_paths = ActionController::Base.view_paths
    av.class_eval do
      include Rails.application.routes.url_helpers
      include ApplicationHelper
      def protect_against_forgery?
        false
      end
    end
    av
  end
  
  def self.tempfile(pdf_string)
    name = Time.now.to_i.to_s
    tempfile = Tempfile.new([name, ".pdf"], Rails.root.join('tmp'))
    tempfile.binmode
    tempfile.write pdf_string
    tempfile.close
    tempfile
  end
  
  def self.render_pdf(lease, invoice, invoice_date)
    building_id = lease.apartment.building.id
    period = charge_period(lease, invoice_date)
    pdf_html = renderer.render :template => "layouts/invoice.html.erb", :layout => nil, encoding: 'utf8',
                               :locals => {:company => Company.first, :lease => lease, :invoice => invoice, 
                                           :invoice_date => invoice_date, :month_description => month_description(period),
                                           :setup => (Setup.where(:building_id => building_id).first || Setup.new) }
    WickedPdf.new.pdf_from_string(pdf_html, :page_size => "Letter")
  end
  
  def self.get_invoice_number(lease, invoice_date=Date.today)
    building_id = lease.apartment.building.id
    i = Invoice.where("created_at >= ? AND created_at <= ? AND building_id = ?", 
                  invoice_date.at_beginning_of_year, invoice_date.end_of_year, building_id).order("number DESC").first
    return 1 unless i
    i.try(:number).try(:+, 1)
  end
  
  def self.get_available_bollo(invoice)
    if invoice.lease.contract && invoice.lease.contract.iva_exempt?
      Bollo.where("invoice_id IS NULL").order("identifier ASC").first
    end
  end
  
end