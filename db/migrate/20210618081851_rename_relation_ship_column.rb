class RenameRelationShipColumn < ActiveRecord::Migration[6.1]
  def change
    rename_column :vaccination_users, :relation_ship, :relationship
  end
end
