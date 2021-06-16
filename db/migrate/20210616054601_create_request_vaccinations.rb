class CreateRequestVaccinations < ActiveRecord::Migration[6.1]
  def change
    create_table :request_vaccinations do |t|
      t.references :share_request, null: false, foreign_key: true
      t.references :vaccination_record, null: false, foreign_key: true

      t.timestamps
    end
  end
end
