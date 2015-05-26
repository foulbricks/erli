class AddIvaFieldsToCompanies < ActiveRecord::Migration
  def change
    add_column :companies, :iva, :decimal, precision: 15, scale: 2
    add_column :companies, :istat, :decimal, precision: 15, scale: 2
    add_column :companies, :words_iva_exempt, :text
    add_column :companies, :codice_fiscale, :string
  end
end
