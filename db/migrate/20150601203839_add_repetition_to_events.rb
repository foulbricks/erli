class AddRepetitionToEvents < ActiveRecord::Migration
  def change
    add_column :events, :parent, :integer
    add_column :events, :repeat, :boolean, :default => false
    add_column :events, :frequency, :string
    add_column :events, :frequency_number, :integer
    add_column :events, :frequency_weekdays, :string
  end
end
