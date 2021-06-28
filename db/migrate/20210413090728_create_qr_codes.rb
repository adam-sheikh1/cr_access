class CreateQrCodes < ActiveRecord::Migration[6.1]
  def change
    create_table :qr_codes, id: :uuid do |t|
      t.string :code
      t.references :codeable, polymorphic: true, type: :uuid

      t.timestamps
    end

    add_index :qr_codes, :created_at
  end
end
