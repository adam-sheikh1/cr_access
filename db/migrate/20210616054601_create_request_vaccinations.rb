class CreateRequestVaccinations < ActiveRecord::Migration[6.1]
  def change
    create_table :request_vaccinations, id: :uuid do |t|
      t.references :share_request, type: :uuid, null: false, foreign_key: true
      t.references :vaccination_record, type: :uuid, null: false, foreign_key: true

      t.timestamps
    end
  end
end
