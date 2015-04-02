class CreateInvoiceRunners < ActiveRecord::Migration
  def change
    create_table :invoice_runners do |t|
      t.date      :generated_date
      t.integer   :building_id
      
      t.timestamps
    end
  end
end
