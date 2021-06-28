class CreateCrAccessGroups < ActiveRecord::Migration[6.1]
  def change
    create_table :cr_access_groups, id: :uuid do |t|
      t.references :cr_access_data, type: :uuid
      t.references :cr_group, type: :uuid

      t.timestamps
    end

    add_index :cr_access_groups, :created_at
    add_index :cr_access_groups, [:cr_access_data_id, :cr_group_id], unique: true
    add_index :cr_access_groups, [:cr_group_id, :cr_access_data_id], unique: true
  end
end
