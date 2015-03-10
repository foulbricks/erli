class CreateUnpaidAlarms < ActiveRecord::Migration
  def change
    create_table :unpaid_alarms do |t|
      t.text      :body
      t.integer   :days, :default => 0
      t.integer   :building_id
      t.timestamps
    end
  end
end
