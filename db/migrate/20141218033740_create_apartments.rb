class CreateApartments < ActiveRecord::Migration
  def change
    create_table :apartments do |t|
      t.string :name
      t.integer :rooms
      t.integer :building_id
      t.integer :dimension
      t.integer :floor

      t.timestamps
    end
  end
end
