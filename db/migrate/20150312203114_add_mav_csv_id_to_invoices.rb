class AddMavCsvIdToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :mav_csv_id, :integer
  end
end
