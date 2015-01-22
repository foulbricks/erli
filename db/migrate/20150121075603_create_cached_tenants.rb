class CreateCachedTenants < ActiveRecord::Migration
  def change
    create_table :cached_tenants do |t|
      t.string :name
      t.string :codice_fiscale
      t.boolean :partita_iva
      t.decimal :percentage, :precision => 15, :scale => 2
      t.string :email
      t.integer :lease_id
      
      t.timestamps
    end
  end
end
