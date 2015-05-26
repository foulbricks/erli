class AddDayAndMonthToBalanceDate < ActiveRecord::Migration
  def change
    add_column :balance_dates, :day, :integer
    add_column :balance_dates, :month, :integer
  end
end
