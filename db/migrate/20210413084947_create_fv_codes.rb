class CreateFvCodes < ActiveRecord::Migration[6.1]
  def change
    create_table :fv_codes, id: :uuid do |t|
      t.string :code
      t.references :fv_codable, polymorphic: true, type: :uuid

      t.timestamps
    end

    add_index :fv_codes, :created_at
  end
end
