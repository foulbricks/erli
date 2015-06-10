class Invoice < ActiveRecord::Base
  include InvoiceViewHelper
  include InvoiceRentHelper
  include InvoiceExpenseHelper
  
  attr_accessor :temporary_bollo
  
  mount_uploader :document, DocumentUploader
  has_many :invoice_charges, :dependent => :destroy
  has_many :asset_expenses, :dependent => :nullify
  has_many :mavs, :dependent => :destroy
  has_one :bollo, :dependent => :nullify
  has_many :invoice_runners, :dependent => :destroy
  belongs_to :lease
  belongs_to :mav_csv
  
  validates_presence_of :lease_id
  
  accepts_nested_attributes_for :invoice_charges, reject_if: proc { |attributes| attributes['amount'].blank? }
  
  before_save do |i|
    self.total = Invoice.calculate_total(self.lease, self)
  end
  
  before_create do |i|
    self.calculate_delivery_date
  end
  
  def approved?
    approved #or Date.today >= (start_date + 1.month)
  end
  
  def status
    if mav_csv_id.nil?
      if approved?
        "Approvato"
      else
        ""
      end
    else
      if mav_csv && mav_csv.uploaded?
        "Scaricato"
      else
        "Approvato"
      end
    end
  end
  
  def periodo
    if Date.same_month?(start_date, end_date)
      I18n.t("date.month_names")[start_date.month].titleize + ", " + start_date.year.to_s
    else
      I18n.t("date.month_names")[start_date.month].titleize + ", " + start_date.year.to_s + " - " +
      I18n.t("date.month_names")[end_date.month].titleize + ", " + end_date.year.to_s
    end
  end
  
  def create_mavs
    setup = Setup.where("building_id = ?", self.building_id).first
    lease.users(:secondary => false).each do |user|
      if !user.secondary? && !mavs.where("user_id = ?", user.id).first
        m = Mav.new
        m.user_id = user.id
        m.building_id = building_id
        m.invoice_id = id
        m.expiration = Mav.calculate_expiration(setup, self)
        m.save
      end
    end
  end
  
  # For manually entered invoices
  def populate(building_id)
    if self.valid?
      self.start_date = Date.today.at_beginning_of_month
      self.end_date = Date.today.end_of_month
      self.building_id = building_id
      self.number = Invoice.get_invoice_number(self.lease)
      
      self.invoice_charges.each do |ic|
        ic.start_date = Date.today.at_beginning_of_month
        ic.end_date = Date.today.end_of_month
        ic.lease_id = self.lease_id
      end
      
      self.temporary_bollo = Invoice.get_available_bollo(self)
      self.create_pdf
    end
  end
  
  def post_save
    self.temporary_bollo.update_column(:invoice_id, self.id) if self.temporary_bollo
    self.invoice_charges.where(:kind => "apartment_expense").all.each do |i|
      i.asset_expense.update_column(:invoice_id, self.id) if i.asset_expense.asset_type == "Apartment"
    end
    self.create_mavs
  end
  
  def calculate_delivery_date
    setup = Setup.where(:building_id => self.building_id).first
    if setup && setup.invoice_delivery.present?
      deliver = self.created_at.change(:day => setup.invoice_delivery)
    else
      deliver = self.created_at.end_of_month
    end
    deliver = deliver.next_month if deliver <= self.created_at
    self.delivery_date = deliver
  end
  
  def create_pdf(invoice_date=nil)
    invoice_date ||= Date.today
    temp = Invoice.tempfile(Invoice.render_pdf(self.lease, self, invoice_date))
    self.document = File.open temp.path
    temp.unlink
  end
  
  
  def self.generate(building_id, invoice_date=Date.today)
    company = Company.first || Company.new
    
    # If the invoice generation is on a day more than 20, set it to next month (was asked 25, but setting 20 to
    # be on the safe side)
    invoice_date = invoice_date.next_month.at_beginning_of_month if invoice_date.day > 20
    
    # Looping through all the registered leases. Invoice generation is done when a lease has been registered or
    # when the lease has been set to confirmed (on contracts page)
  
    registered_leases(building_id, invoice_date).each do |lease|
      
      # Invoices for trimester leases are only generated on January, April, July and October [1, 4, 7, 10]
      # An invoice will also be generated on the last month of lease, in case there are apartment expenses
      # still lingering to be paid, so skip generation if it doesn't comply to these cases
      next if lease.payment_frequency == 3 && !invoice_date.month.in?([1, 4, 7, 10]) && 
              !Date.same_month?(invoice_date, lease.end_date + 1.month)
      
      # Adding a runner for every lease so the invoices are not generated twice in the same month by mistake. The invoice
      # will need to be deleted in order to create a new one on the same month
      # NOTE that InvoiceRunners skipped if on a trimester month or if a needed bollo is unaivailable
      runner = InvoiceRunner.where("lease_id = ? AND generated_date BETWEEN ? AND ?", lease.id, 
              invoice_date.at_beginning_of_month, invoice_date.end_of_month).first
      
      if runner.nil?
        invoice = self.new(:building_id => building_id, :number => get_invoice_number(lease, invoice_date), :lease_id => lease.id)
                           
        # last_generated is only used for monthly leases
        last_runner = InvoiceRunner.where("lease_id = ? AND generated_date BETWEEN ? AND ?", lease.id, 
               invoice_date.prev_month.at_beginning_of_month, invoice_date.prev_month.end_of_month).first
        last_generated = last_runner.generated_date if last_runner
        
        period = charge_rent(lease, invoice, invoice_date, company, last_generated)
        invoice.start_date = period ? period.first : invoice_date.at_beginning_of_month
        invoice.end_date = period ? period.last : invoice_date.end_of_month
        
        charge_conguaglio_expenses(lease, invoice, invoice_date) if period
        charge_apartment_expenses(lease, invoice)
    
        unless calculate_total(lease, invoice) == 0
          invoice.temporary_bollo = get_available_bollo(invoice)

          next if invoice.lease.contract && invoice.lease.contract.iva_exempt? && invoice.temporary_bollo.nil?

          invoice.create_pdf(invoice_date)
          invoice.post_save if invoice.save
        end
        
        unless invoice.new_record?
          InvoiceRunner.create(:lease_id => lease.id, :invoice_id => invoice.id, :generated_date => invoice_date)
        end
        
      end
    end
  end
  
  def self.registered_leases(building_id, invoice_date=Date.today)
    apartment_ids = Apartment.where(:building_id => building_id).all.map(&:id)
    Lease.where("active = ? AND apartment_id IN (?) AND (registration_date IS NOT NULL OR confirmed = ?)",
                true, apartment_ids, true).all
  end
  
  def self.calculate_total(lease, invoice)
    bollo = invoice.bollo || invoice.temporary_bollo
    without_iva = invoice.invoice_charges.select {|i| i.iva_exempt? }
    with_iva = invoice.invoice_charges.select {|i| !i.iva_exempt? }
    total_iva = with_iva.map(&:amount).sum
    total_without_iva = without_iva.map(&:amount).sum
    company = Company.first || Company.new
    iva = lease.contract.try(:iva_exempt?) || company.iva.nil? ? 0 : (total_iva * company.iva/100.0)
    bollo_total = bollo ? bollo.price : 0
    total_iva + total_without_iva + iva + bollo_total
  end
  
  def self.get_invoice_number(lease, invoice_date=Date.today)
    building_id = lease.apartment.building.id
    i = Invoice.where("start_date >= ? AND start_date <= ?", 
                  invoice_date.at_beginning_of_year, invoice_date.end_of_year).order("number DESC").first
    return 1 unless i
    i.try(:number).try(:+, 1)
  end
  
  def self.get_available_bollo(invoice)
    if invoice.lease.contract && invoice.lease.contract.iva_exempt?
      bollo = Bollo.where("invoice_id IS NULL").order("identifier ASC").first
      unless bollo
        Event.create(:title => "Bollo Non Trovato",
                     :description => "Si Prega di comprare di piu. Fattura Numero #{ invoice.number }",
                     :building_id => invoice.building_id,
                     :color => "#d9534f",
                     :start => Date.today,
                     :finish => Date.today,
                     :kind => "bollo",
                     :active => true)
      end
      bollo
    end
  end
  
end