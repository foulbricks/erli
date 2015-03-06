class AddWelcomeAndResetPasswordFieldsToCompany < ActiveRecord::Migration
  def change
    add_column :companies, :welcome_text, :text
    add_column :companies, :reset_password_text, :text
  end
end
