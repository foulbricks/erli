class AddIvaExemptionToExpensesAndContracts < ActiveRecord::Migration
  def change
    add_column :contracts, :iva_exempt, :boolean, :default => false
    add_column :expenses,  :iva_exempt, :boolean, :default => false
  end
end
