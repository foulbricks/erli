class AddAddressFieldsAndBackgroundToBuilding < ActiveRecord::Migration
  def change
    add_column :buildings, :localita, :string
    add_column :buildings, :provincia, :string
    add_column :buildings, :cap,       :string
    add_column :buildings, :background, :string
    add_column :buildings, :home_number, :string
  end
end
