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
  
  def create_pdf
    temp = Invoice.tempfile(Invoice.render_pdf(self.lease, self, Date.today))
    self.document = File.open temp.path
    temp.unlink
  end
  
  
  def self.generate(building_id, invoice_date=Date.today)  
    csv = MavCsv.where("generated = ?", Date.today).first
    csv = MavCsv.create!(:building_id => building_id, :generated => invoice_date) unless csv
    company = Company.first || Company.new
  
    registered_leases(building_id, invoice_date).each do |lease|
      runner = InvoiceRunner.where("lease_id = ? AND created_at BETWEEN ? AND ?", lease.id, 
              invoice_date.at_beginning_of_month, invoice_date.end_of_month).first
      last_runner = InvoiceRunner.where("lease_id = ? AND created_at BETWEEN ? AND ?", lease.id, 
              invoice_date.prev_month.at_beginning_of_month, invoice_date.prev_month.end_of_month).first
      
      if runner.nil?
        invoice = self.new(:building_id => building_id, :number => get_invoice_number(lease, invoice_date),
                           :lease_id => lease.id, :start_date => invoice_date.at_beginning_of_month,
                           :end_date => invoice_date.end_of_month, :mav_csv_id => csv.id)
      
        last_generated = last_runner.generated_date if last_runner
        charge_rent(lease, invoice, invoice_date, company, last_generated)
    
        if (lease.start_date..lease.end_date).include?(invoice_date)
          charge_conguaglio_expenses(lease, invoice, last_generated, invoice_date)
          charge_apartment_expenses(lease, invoice, invoice_date)
        end
    
        unless calculate_total(lease, invoice) == 0
          invoice.temporary_bollo = get_available_bollo(invoice)
          invoice.create_pdf
  
          if invoice.save
            invoice.post_save
          end
        end
        
        unless (invoice.lease.contract && invoice.lease.contract.iva_exempt? && invoice.bollo.nil?) || invoice.new_record?
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
    i = Invoice.where("start_date >= ? AND start_date <= ? AND building_id = ?", 
                  invoice_date.at_beginning_of_year, invoice_date.end_of_year, building_id).order("number DESC").first
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