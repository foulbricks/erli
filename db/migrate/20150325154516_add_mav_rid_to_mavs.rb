class AddMavRidToMavs < ActiveRecord::Migration
  def change
    add_column :mavs, :mav_rid, :string
    add_column :mavs, :expiration, :date
    add_column :mavs, :status, :string, :default => "Da Pagare"
  end
end
