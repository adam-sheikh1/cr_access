class CreateCrAccessGroups < ActiveRecord::Migration[6.1]
  def change
    create_table :cr_access_groups do |t|
      t.references :cr_access_data
      t.references :cr_group

      t.timestamps
    end

    add_index :cr_access_groups, [:cr_access_data_id, :cr_group_id], unique: true
    add_index :cr_access_groups, [:cr_group_id, :cr_access_data_id], unique: true
  end
end
