class AddLeaseColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :codice_fiscale, :string
    add_column :users, :codice_salt, :string
    add_column :users, :secondary, :boolean,  :default => false
    add_column :users, :lease_id, :integer
  end
end
