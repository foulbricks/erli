class CreateAssetExpenses < ActiveRecord::Migration
  def change
    create_table :asset_expenses do |t|
      t.references  :asset, :polymorphic => true
      t.integer     :expense_id
      t.decimal     :amount, :precision => 15, :scale => 2
      
      t.timestamps
    end
  end
end


