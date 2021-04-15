class CreateFvCodes < ActiveRecord::Migration[6.1]
  def change
    create_table :fv_codes do |t|
      t.string :code
      t.references :fv_codable, polymorphic: true

      t.timestamps
    end
  end
end
