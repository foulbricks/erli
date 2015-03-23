class AddIbanToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :email, :string
    add_column :companies, :iban, :string
  end
end
