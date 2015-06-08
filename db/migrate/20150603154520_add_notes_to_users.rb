class AddNotesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :phone, :string
    add_column :users, :notes, :text
  end
end
