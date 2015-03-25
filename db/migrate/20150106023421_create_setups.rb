class CreateSetups < ActiveRecord::Migration
  def change
    create_table :setups do |t|
      t.date :balance_expenses
      t.decimal :iva, :precision => 15, :scale => 2
      t.decimal :istat, :precision => 15, :scale => 2
      t.integer :mav_expiration
      t.integer :invoice_generation, :default => 25
      t.integer :invoice_delivery
      t.text :unpaid_sentence
      t.string :erli_mav_email
      t.boolean :erli_mav_email_active, :default => false
      t.string :erli_admin_email
      t.integer :building_id

      t.timestamps
    end
  end
end
