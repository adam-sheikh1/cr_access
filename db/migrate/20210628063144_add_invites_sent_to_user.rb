class AddInvitesSentToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :total_invites_sent, :integer
    add_column :users, :invites_sent_at, :date
  end
end
