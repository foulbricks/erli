class AddItemizedToSetup < ActiveRecord::Migration
  def change
    add_column :setups, :itemized_expenses, :boolean, :default => false
  end
end
