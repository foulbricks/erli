class CreateInvoiceRunners < ActiveRecord::Migration
  def change
    create_table :invoice_runners do |t|
      t.date      :generated_date
      t.integer   :lease_id
      
      t.timestamps
    end
  end
end
