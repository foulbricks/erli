class CreateSetups < ActiveRecord::Migration
  def change
    create_table :setups do |t|
      t.date :balance_expenses
      t.decimal :iva
      t.decimal :istat
      t.integer :mav_expiration
      t.integer :invoice_generation
      t.integer :invoice_delivery
      t.text :unpaid_sentence
      t.string :erli_mav_email
      t.boolean :erli_mav_email_active
      t.string :erli_admin_email
      t.integer :building_id

      t.timestamps
    end
  end
end
