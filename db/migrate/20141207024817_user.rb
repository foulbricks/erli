class User < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string  :first_name
      t.string  :last_name
      t.string  :email
      t.string  :password
      t.string  :salt
      t.boolean :admin, :default => false
      t.string  :pwcode
      t.string  :activation_code
      t.datetime :activation_code_set_at
      t.string  :pw_code
      t.string  :pw_code_set_at
      t.boolean :active, :default => false
      
      t.timestamps
    end
  end
end
