class ChangePrepmodPatientIdType < ActiveRecord::Migration[6.1]
  def up
    change_column :cr_access_data, :prepmod_patient_id, :string
  end

  def down
    change_column :cr_access_data, :prepmod_patient_id, :bigint
  end
end
