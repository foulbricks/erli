class AddDependenciesToAssetExpenses < ActiveRecord::Migration
  def change
    add_column :asset_expenses, :invoice_id, :integer
    add_column :asset_expenses, :lease_id, :integer
    add_column :asset_expenses, :paid_on, :date
  end
end
