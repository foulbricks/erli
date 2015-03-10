class CreateUnpaidWarnings < ActiveRecord::Migration
  def change
    create_table :unpaid_warnings do |t|
      t.text      :text
      t.integer   :days,    :default => 0
      t.string    :background
      t.boolean   :flashing, :default => false
      t.integer   :building_id
      t.timestamps
    end
  end
end
