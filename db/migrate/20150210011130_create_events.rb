class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string        :title
      t.text          :description
      t.datetime      :start
      t.datetime      :finish
      t.string        :color
      t.integer       :building_id
      t.integer       :apartment_id
      t.integer       :lease_id
      t.integer       :user_id
      t.boolean       :active
      t.string        :kind
      
      t.timestamps
    end
  end
end
