class AddFieldsToCrDataUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :cr_data_users, :status, :string, default: 'pending'
    add_index :cr_data_users, %i[cr_access_data_id user_id], unique: true
    add_index :cr_data_users, %i[user_id cr_access_data_id], unique: true
  end
end
