class CreateAds < ActiveRecord::Migration
  def change
    create_table :ads do |t|
      t.integer :user_id
      t.integer :building_id
      t.text    :description
      t.decimal :amount
      t.string  :contact
      t.boolean :approved, :default => false
      t.date    :end_date
      
      t.timestamps
    end
  end
end
