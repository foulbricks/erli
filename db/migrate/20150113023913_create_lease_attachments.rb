class CreateLeaseAttachments < ActiveRecord::Migration
  def change
    create_table :lease_attachments do |t|
      t.integer :lease_id
      t.string  :document
      t.boolean :lease_document, :default => false
      t.timestamps
    end
  end
end
