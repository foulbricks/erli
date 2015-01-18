class AddDatesToAssetExpenses < ActiveRecord::Migration
  def change
    add_column :asset_expenses, :start_date, :date
    add_column :asset_expenses, :end_date, :date
  end
end
