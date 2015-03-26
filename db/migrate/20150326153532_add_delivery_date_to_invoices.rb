class AddDeliveryDateToInvoices < ActiveRecord::Migration
  def change
    add_column :invoices, :delivery_date, :date
  end
end
