class AddExtraLeaseColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :partita_iva, :boolean
    add_column :users, :percentage, :decimal, precision: 15, scale: 2, default: 0.0
    add_column :users, :tenant_id, :integer
    remove_column :leases, :partita_iva, :boolean
    remove_column :leases, :percentage, :decimal
    remove_column :leases, :name, :string
    remove_column :leases, :codice_fiscale, :string
    remove_column :leases, :email, :string
  end
end
