class CreateAdAttachments < ActiveRecord::Migration
  def change
    create_table :ad_attachments do |t|
      t.integer   :ad_id
      t.string    :image
      
      t.timestamps
    end
  end
end
