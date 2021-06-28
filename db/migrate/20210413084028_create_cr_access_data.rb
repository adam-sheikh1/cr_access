class CreateCrAccessData < ActiveRecord::Migration[6.1]
  def change
    create_table :cr_access_data, id: :uuid do |t|
      t.string :email
      t.string :first_name
      t.string :last_name
      t.string :gender
      t.string :address
      t.string :city
      t.string :state
      t.string :zip_code
      t.string :phone_number
      t.date :date_of_birth
      t.bigint :prepmod_patient_id
      t.string :vaccination_status
      t.boolean :primary, default: false
      t.references :user, type: :uuid

      t.timestamps
    end

    add_index :cr_access_data, :created_at
  end
end
