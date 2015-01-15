class CreateContracts < ActiveRecord::Migration
  def change
    create_table :contracts do |t|
      t.string :name
      t.decimal :istat, :precision => 15, :scale => 2

      t.timestamps
    end
  end
end
