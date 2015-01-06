class CreateContracts < ActiveRecord::Migration
  def change
    create_table :contracts do |t|
      t.string :name
      t.decimal :istat

      t.timestamps
    end
  end
end
