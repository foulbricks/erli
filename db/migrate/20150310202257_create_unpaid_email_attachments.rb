class CreateUnpaidEmailAttachments < ActiveRecord::Migration
  def change
    create_table :unpaid_email_attachments do |t|
      t.integer   :unpaid_email_id
      t.string    :document

      t.timestamps
    end
  end
end
