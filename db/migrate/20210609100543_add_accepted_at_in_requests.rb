class AddAcceptedAtInRequests < ActiveRecord::Migration[6.1]
  def change
    add_column :share_requests, :accepted_at, :datetime
  end
end
