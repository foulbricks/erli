class AddHomeNumberToLease < ActiveRecord::Migration
  def change
    add_column :leases, :home_number, :string
  end
end
