class AddColumnsToCrDataUsers < ActiveRecord::Migration[6.1]
  def change
    add_column :cr_data_users, :primary, :boolean, default: false
    add_column :cr_data_users, :data_type, :string
    remove_column :cr_access_data, :user_id, :bigint
    remove_column :cr_access_data, :primary, :boolean

    add_index :cr_data_users, %i[status data_type]
  end
end
