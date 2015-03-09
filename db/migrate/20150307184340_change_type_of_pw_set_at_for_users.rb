class ChangeTypeOfPwSetAtForUsers < ActiveRecord::Migration
  def up
    remove_column :users, :pw_code_set_at
    add_column :users, :pw_code_set_at, :datetime
  end
  
  def down
    remove_column :users, :pw_code_set_at
    add_column :users, :pw_code_set_at, :string
  end
end
