class CreateCrAccessData < ActiveRecord::Migration[6.1]
  def change
    create_table :cr_access_data do |t|
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
      t.bigint :parent_id
      t.boolean :primary, default: false
      t.bigint :patient_id
      t.references :user

      t.timestamps
    end
  end
end
