class CreateMavCsvs < ActiveRecord::Migration
  def change
    create_table :mav_csvs do |t|
      t.integer   :building_id
      
      t.timestamps
    end
  end
end
