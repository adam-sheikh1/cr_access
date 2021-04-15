class CreateCrGroups < ActiveRecord::Migration[6.1]
  def change
    create_table :cr_groups do |t|
      t.string :name
      t.string :group_type
      t.references :user

      t.timestamps
    end
  end
end
