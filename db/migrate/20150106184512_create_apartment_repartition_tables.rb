class CreateApartmentRepartitionTables < ActiveRecord::Migration
  def change
    create_table :apartment_repartition_tables do |t|
      t.belongs_to :apartment, index: true
      t.belongs_to :repartition_table, index: true
      t.decimal :percentage
      t.integer :floor
      t.string :name
      
      t.timestamps
    end
  end
end