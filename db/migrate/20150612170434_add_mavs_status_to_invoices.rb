class AddMavsStatusToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :mavs_status, :string
    add_column :mavs, :uploaded_amount, :decimal, :precision => 15, :scale => 2
  end
end
