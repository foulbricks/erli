class CreateMavs < ActiveRecord::Migration
  def change
    create_table :mavs do |t|
      t.integer     :building_id
      t.integer     :user_id
      t.integer     :invoice_id
      t.string      :document
      t.date        :last_paid_on
      t.decimal     :amount_paid
      
      t.timestamps
    end
  end
end
