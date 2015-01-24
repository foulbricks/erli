class CreateExpenseAttachments < ActiveRecord::Migration
  def change
    create_table :expense_attachments do |t|
      t.integer :asset_expense_id
      t.string :document

      t.timestamps
    end
  end
end
