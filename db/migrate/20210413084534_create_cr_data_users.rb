class CreateCrDataUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :cr_data_users, id: :uuid do |t|
      t.references :cr_access_data, type: :uuid
      t.references :user, type: :uuid

      t.timestamps
    end

    add_index :cr_data_users, :created_at
  end
end
