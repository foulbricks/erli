class CreateBollos < ActiveRecord::Migration
  def change
    create_table :bollos do |t|
      t.string  :identifier
      t.decimal :price
      t.integer :invoice_id
      t.integer :bollo_range_id
      
      t.timestamps
    end
  end
end
