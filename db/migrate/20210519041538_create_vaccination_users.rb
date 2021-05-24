class CreateVaccinationUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :vaccination_users do |t|
      t.references :vaccination_record
      t.references :user
      t.string :relation_ship

      t.timestamps
    end

    add_index :vaccination_users, %i[user_id vaccination_record_id], unique: true
    add_index :vaccination_users, %i[vaccination_record_id user_id], unique: true
  end
end
