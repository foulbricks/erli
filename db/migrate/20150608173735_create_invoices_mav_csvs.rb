class CreateInvoicesMavCsvs < ActiveRecord::Migration
  def change
    create_table :invoices_mav_csvs, id: false do |t|
      t.belongs_to :invoice, index: true
      t.belongs_to :mav_csv, index: true
    end
  end
end
