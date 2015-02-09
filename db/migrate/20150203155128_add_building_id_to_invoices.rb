class AddBuildingIdToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :building_id, :integer
    add_column :invoices, :start_date, :date
    add_column :invoices, :end_date, :date
    add_column :invoices, :total, :decimal, :precision => 15, :scale => 2, :default => 0
    add_column :invoices, :approved, :boolean
  end
end
