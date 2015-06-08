class AddApprovedAndActiveToMavCsvs < ActiveRecord::Migration
  def change
    add_column :mav_csvs, :uploaded, :boolean, :default => false
    add_column :mav_csvs, :active, :boolean, :default => true
  end
end
