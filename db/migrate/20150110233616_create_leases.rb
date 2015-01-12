class CreateLeases < ActiveRecord::Migration
  def change
    create_table :leases do |t|
      t.decimal     :percentage, :default => 0, :null => false
      t.belongs_to  :contract
      t.belongs_to  :apartment
      t.string      :invoice_address
      t.date        :start_date
      t.date        :end_date
      t.decimal     :amount
      t.integer     :payment_frequency
      t.decimal     :deposit
      t.date        :registration_date
      t.integer     :registration_number
      t.string      :registration_agency

      t.timestamps
    end
  end
end
