class AssetExpense < ActiveRecord::Base
  belongs_to :asset, polymorphic: true
  belongs_to :expense
  belongs_to :invoice
  belongs_to :lease
  
  has_one :expense_attachment, :dependent => :destroy
  has_many :invoice_charges
  
  accepts_nested_attributes_for :expense_attachment, :reject_if => proc {|attrs| attrs["document"].blank? }
  
  validates :expense_id, :amount, :presence => true
  validates :amount, :numericality => true
  validate :lease_presence
  
  # Saves lease on asset_expense if an active lease is present
  def lease_presence
    if asset_type == "Apartment"
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
