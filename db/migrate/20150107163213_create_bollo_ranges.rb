class CreateBolloRanges < ActiveRecord::Migration
  def change
    create_table :bollo_ranges do |t|
      t.integer :from
      t.integer :to
      t.decimal :price, :precision => 15, :scale => 2

      t.timestamps
    end
  end
end
