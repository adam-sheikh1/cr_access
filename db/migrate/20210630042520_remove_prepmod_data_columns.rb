class RemovePrepmodDataColumns < ActiveRecord::Migration[6.1]
  def change
    remove_column :cr_access_data, :first_name, :string
    remove_column :cr_access_data, :last_name, :string
    remove_column :cr_access_data, :gender, :string
    remove_column :cr_access_data, :address, :string
    remove_column :cr_access_data, :city, :string
    remove_column :cr_access_data, :state, :string
    remove_column :cr_access_data, :zip_code, :string
    remove_column :cr_access_data, :phone_number, :string
    remove_column :cr_access_data, :date_of_birth, :date
    remove_column :cr_access_data, :vaccination_status, :string

    remove_column :vaccination_records, :clinic_name, :string
    remove_column :vaccination_records, :clinic_location, :string
    remove_column :vaccination_records, :dose_volume, :string
    remove_column :vaccination_records, :dose_volume_units, :string
    remove_column :vaccination_records, :lot_number, :string
    remove_column :vaccination_records, :manufacturer_name, :string
    remove_column :vaccination_records, :reaction, :string
    remove_column :vaccination_records, :route, :string
    remove_column :vaccination_records, :site, :string
    remove_column :vaccination_records, :vaccination_date, :datetime
    remove_column :vaccination_records, :vaccine_name, :string
    remove_column :vaccination_records, :vaccine_expiration_date, :datetime

    add_column :cr_access_data, :external_id, :string
    add_index :cr_access_data, :external_id, unique: true
    add_index :cr_access_data, :prepmod_patient_id, unique: true
  end
end
