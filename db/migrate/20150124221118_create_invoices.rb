class CreateInvoices < ActiveRecord::Migration
  def change
    create_table :invoices do |t|
      t.integer :number
      t.integer :lease_id
      t.string :document

      t.timestamps
    end
  end
end
