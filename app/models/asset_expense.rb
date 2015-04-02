# Expense
# Building Expense            # Apartment Expense      # Lease Expense (type building)
  # Apartment Expense           # Belongs to Lease
  # Has apartment_expense_id
  
class AssetExpense < ActiveRecord::Base
  belongs_to :asset, polymorphic: true
  belongs_to :expense
  belongs_to :invoice
  belongs_to :lease
  
  has_one :expense_attachment, :dependent => :destroy
  has_many :invoice_charges
  has_many :apartment_expenses, class_name: "AssetExpense", foreign_key: "apartment_expense_id", :dependent => :destroy
  belongs_to :apartment_expense, class_name: "AssetExpense"
  
  accepts_nested_attributes_for :expense_attachment, :reject_if => proc {|attrs| attrs["document"].blank? }
  
  validates :expense_id, :amount, :presence => true
  validates :amount, :numericality => true
  validate :lease_presence
  
  before_save :cache_apartment_expenses, :cache_balance_date
  
  private
  
  def cache_apartment_expenses
    if asset_type == "Building"
      if self.new_record?
        self.expense.try(:repartition_table).try(:apartment_repartition_tables).try(:each) do|rt|
          if rt.percentage && rt.percentage > 0
            begin
              am = rt.percentage/100.0 * self.amount
              self.apartment_expenses.build(:asset_id => rt.apartment_id, :asset_type => "Apartment",
              :expense_id => self.expense.id, :amount => am, :start_date => self.start_date,
              :end_date => self.end_date, :balance_date => self.expense.try(:balance_date).try(:value),
              :apartment_expense_id => self.id)
            rescue
            end
          end
        end
      else
        self.apartment_expenses.each do |ae|
          begin
            rt = self.expense.repartition_table.apartment_repartition_tables.where(:apartment_id => ae.asset_id).first
            am = rt.percentage/100.0 * self.amount
            ae.update_column(:amount, am)
          rescue
          end
        end
      end
    end
  end
  
  def cache_balance_date
    if asset_type == "Apartment" and apartment_expense_id.nil?
      if b = self.expense.try(:balance_date)
        self.balance_date = b.value
      end
    end
  end
  
  # Saves lease on asset_expense if an active lease is present
  def lease_presence
    if asset_type == "Apartment" and apartment_expense_id.nil?
      begin
        if(l = asset.active_leases.first)
          self.lease_id = l.id
        else
          errors.add(:base, "Un contratto di locazione attivo per l'appartamento non ha stato trovato")
        end
      rescue => e
        errors.add(:base, "An unexpected error occurred while detecting an active lease #{e}")
      end
    end
  end
  
end
