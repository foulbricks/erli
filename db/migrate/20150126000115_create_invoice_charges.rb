class CreateInvoiceCharges < ActiveRecord::Migration
  def change
    create_table :invoice_charges do |t|
      t.decimal   :amount, :precision => 15, :scale => 2
      t.date      :start_date
      t.date      :end_date
      t.integer   :invoice_id
      t.date      :paid_on
      t.boolean   :paid,        :default => false
      t.string    :kind
      t.integer   :asset_expense_id
      
      t.timestamps
    end
  end
end
