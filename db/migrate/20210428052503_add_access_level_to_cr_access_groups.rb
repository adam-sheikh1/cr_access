class AddAccessLevelToCrAccessGroups < ActiveRecord::Migration[6.1]
  def change
    add_column :cr_access_groups, :access_level, :string, default: 'anyone'
  end
end
