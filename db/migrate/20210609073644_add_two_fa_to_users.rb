class AddTwoFaToUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :two_fa_code, :string
    add_column :users, :two_fa_sent_at, :datetime
  end
end
