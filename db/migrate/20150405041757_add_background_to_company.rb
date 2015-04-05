class AddBackgroundToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :background, :string
  end
end
