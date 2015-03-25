class AddGeneratedToMavCsvs < ActiveRecord::Migration
  def change
    add_column :mav_csvs, :generated, :date
  end
end
