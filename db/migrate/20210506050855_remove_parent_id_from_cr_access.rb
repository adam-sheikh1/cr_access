class RemoveParentIdFromCrAccess < ActiveRecord::Migration[6.1]
  def change
    remove_column :cr_access_data, :parent_id, :bigint
  end
end
