class AddExpirationDateToVaccinations < ActiveRecord::Migration[6.1]
  def change
    add_column :vaccination_records, :vaccine_expiration_date, :datetime
  end
end
