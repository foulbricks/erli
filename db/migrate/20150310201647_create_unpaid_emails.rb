class CreateUnpaidEmails < ActiveRecord::Migration
  def change
    create_table :unpaid_emails do |t|
      t.text      :body
      t.integer   :days, :default => 0
      t.integer   :frequency, :default => 0
      t.integer   :building_id
      t.timestamps
    end
  end
end
