class AddBalanceDateIdToExpenses < ActiveRecord::Migration
  def change
    add_column :expenses, :balance_date_id, :integer
  end
end
