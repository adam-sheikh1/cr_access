class CreateShareRequests < ActiveRecord::Migration[6.1]
  def change
    create_table :share_requests, id: :uuid do |t|
      t.references :user, type: :uuid, null: false, foreign_key: true
      t.references :recipient, type: :uuid
      t.string :data
      t.text :vaccination_record_ids, array: true, default: []
      t.string :status, default: 'pending'
      t.string :request_type
      t.integer :relationship

      t.timestamps
    end
  end
end
