class AddApartmentExpenseColumnsToAssetExpenses < ActiveRecord::Migration
  def change
    add_column :asset_expenses, :apartment_expense_id, :integer
    add_column :asset_expenses, :balance_date, :date
  end
end
