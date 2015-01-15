class CreateLeases < ActiveRecord::Migration
  def change
    create_table :leases do |t|
      t.decimal     :percentage, :default => 0, :null => false, :precision => 15, :scale => 2
      t.belongs_to  :contract
      t.belongs_to  :apartment
      t.string      :invoice_address
      t.string      :cap
      t.string      :localita
      t.string      :provincia
      t.boolean     :partita_iva, :default => false
      t.date        :start_date
      t.date        :end_date
      t.decimal     :amount, :precision => 15, :scale => 2
      t.integer     :payment_frequency
      t.decimal     :deposit, :precision => 15, :scale => 2
      t.date        :registration_date
      t.integer     :registration_number
      t.string      :registration_agency
      t.boolean     :active,    :default => true
      t.date        :inactive_date
      t.string      :name
      t.string      :codice_fiscale
      t.string      :email
      t.boolean     :resolved, :default => true

      t.timestamps
    end
  end
end
