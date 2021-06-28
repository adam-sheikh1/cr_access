class CreateCrGroups < ActiveRecord::Migration[6.1]
  def change
    create_table :cr_groups, id: :uuid do |t|
      t.string :name
      t.string :group_type
      t.references :user, type: :uuid

      t.timestamps
    end

    add_index :cr_groups, :created_at
  end
end
