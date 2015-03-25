class AddDefaultWarningToSetup < ActiveRecord::Migration
  def change
    add_column :setups, :default_warning, :text
  end
end
