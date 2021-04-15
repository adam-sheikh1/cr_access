class CreateCrDataUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :cr_data_users do |t|
      t.references :cr_access_data
      t.references :user

      t.timestamps
    end
  end
end
