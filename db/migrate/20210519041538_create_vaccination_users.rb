class CreateVaccinationUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :vaccination_users, id: :uuid do |t|
      t.references :vaccination_record, type: :uuid
      t.references :user, type: :uuid
      t.string :relation_ship

      t.timestamps
    end

    add_index :vaccination_users, :created_at
    add_index :vaccination_users, %i[user_id vaccination_record_id], unique: true
    add_index :vaccination_users, %i[vaccination_record_id user_id], unique: true
  end
end
