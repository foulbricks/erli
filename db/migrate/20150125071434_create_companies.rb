class CreateCompanies < ActiveRecord::Migration
  def change
    create_table :companies do |t|
      t.string      :name
      t.string      :address
      t.string      :home_number
      t.string      :provincia
      t.string      :localita
      t.string      :cap
      t.string      :partita_iva
      t.string      :phone
      t.string      :fax
      t.timestamps
    end
  end
end
