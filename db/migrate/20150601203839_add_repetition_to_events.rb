class AddRepetitionToEvents < ActiveRecord::Migration
  def change
    add_column :events, :parent, :integer
    add_column :events, :repeat, :boolean, :default => false
    add_column :events, :frequency, :string
    add_column :events, :frequency_number, :integer
    add_column :events, :frequency_weekdays, :string
    add_column :events, :series_start, :datetime
    add_column :events, :series_finish, :datetime
  end
end
