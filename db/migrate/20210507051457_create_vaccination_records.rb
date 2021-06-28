class CreateVaccinationRecords < ActiveRecord::Migration[6.1]
  def change
    create_table :vaccination_records, id: :uuid do |t|
      t.string :clinic_name
      t.string :clinic_location
      t.string :dose_volume
      t.string :dose_volume_units
      t.string :external_id
      t.string :lot_number
      t.string :manufacturer_name
      t.string :reaction
      t.string :route
      t.string :site
      t.datetime :vaccination_date
      t.string :vaccine_name
      t.references :cr_access_data, type: :uuid

      t.timestamps
    end

    add_index :vaccination_records, :created_at
  end
end
