class CreateExpenses < ActiveRecord::Migration
  def change
    create_table :expenses do |t|
      t.string    :name
      t.string    :kind
      t.boolean   :add_to_invoice, :default => false
      t.boolean   :add_to_conguaglio, :default => false
      t.integer   :building_id
      t.integer   :repartition_table_id
      
      t.timestamps
    end
  end
end
