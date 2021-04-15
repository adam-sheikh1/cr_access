class CreateQrCodes < ActiveRecord::Migration[6.1]
  def change
    create_table :qr_codes do |t|
      t.string :code
      t.references :codeable, polymorphic: true

      t.timestamps
    end
  end
end
