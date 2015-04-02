class AddBalancedToInvoiceCharges < ActiveRecord::Migration
  def change
    add_column :invoice_charges, :balanced, :boolean, :default => false
  end
end
