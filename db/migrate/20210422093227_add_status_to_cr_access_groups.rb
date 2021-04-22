class AddStatusToCrAccessGroups < ActiveRecord::Migration[6.1]
  def change
    add_column :cr_access_groups, :status, :string, default: 'pending'
  end
end
