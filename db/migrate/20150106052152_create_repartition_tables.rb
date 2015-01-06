class CreateRepartitionTables < ActiveRecord::Migration
  def change
    create_table :repartition_tables do |t|
      t.integer :building_id
      t.string :name

      t.timestamps
    end
  end
end
