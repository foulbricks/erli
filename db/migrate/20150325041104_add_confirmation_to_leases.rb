class AddConfirmationToLeases < ActiveRecord::Migration
  def change
    add_column :leases, :confirmed,         :boolean, :default => false
    add_column :leases, :fully_charged,     :boolean, :default => true
  end
end
