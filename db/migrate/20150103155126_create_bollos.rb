class CreateBollos < ActiveRecord::Migration
  def change
    create_table :bollos do |t|
      t.integer :identifier
      t.decimal :price, :precision => 15, :scale => 2
      t.integer :invoice_id
      t.integer :bollo_range_id
      
      t.timestamps
    end
  end
end
