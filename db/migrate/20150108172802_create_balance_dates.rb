class CreateBalanceDates < ActiveRecord::Migration
  def change
    create_table :balance_dates do |t|
      t.integer :building_id
      t.date :value

      t.timestamps
    end
  end
end
