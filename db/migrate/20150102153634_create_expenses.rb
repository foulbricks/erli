class CreateExpenses < ActiveRecord::Migration
  def change
    create_table :expenses do |t|
      t.string    :name
      t.string    :kind
      t.boolean   :add_to_invoice
      t.boolean   :add_to_conguaglio
      t.integer   :building_id
      
      t.timestamps
    end
  end
end
