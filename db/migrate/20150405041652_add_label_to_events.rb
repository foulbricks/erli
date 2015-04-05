class AddLabelToEvents < ActiveRecord::Migration
  def change
    add_column :events, :label, :string
  end
end
