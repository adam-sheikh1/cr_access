class CreateShareRequests < ActiveRecord::Migration[6.1]
  def change
    create_table :share_requests do |t|
      t.references :user
      t.references :recipient
      t.string :data
      t.text :vaccination_record_ids, array: true, default: []
      t.string :status, default: 'pending'
      t.string :request_type
      t.string :relationship

      t.timestamps
    end
  end
end
